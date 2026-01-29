class CardsController < ApplicationController
  before_action :set_card, only: %i[ show edit update destroy ]

  # GET /cards or /cards.json
  def index
    @games = Game.order(:name)
    if params[:game_id].present?
      @cards = Card.where(game_id: params[:game_id]).order(:name)
    else
      @cards = Card.order(:name)
    end
  end

  # GET /cards/1 or /cards/1.json
  def show
  end

  # GET /cards/new
  def new
    @card = Card.new
  end

  # POST /cards/import
  def import
    # Accept file upload (json or xml) or raw text
    content = nil
    if params[:import] && params[:import][:file]
      uploaded = params[:import][:file]
      content = uploaded.read
    elsif params[:import] && params[:import][:raw_text].present?
      content = params[:import][:raw_text]
    end

    if content.blank?
      redirect_to cards_path, alert: 'No import content provided.' and return
    end

    # determine or create target game
    Rails.logger.info "IMPORT PARAMS: "+(params[:import].inspect rescue 'nil')
    game = nil
    if params[:import] && params[:import][:game_id].present? && params[:import][:game_id].to_s =~ /\A\d+\z/
      game = Game.find_by(id: params[:import][:game_id])
    end

    # If user provided a new game name, create / find it (force-create regardless of previous game lookup)
    if params[:import]
      new_name = params[:import][:new_game_name].to_s.strip
      new_edition = params[:import][:new_game_edition].to_s.strip
      if new_name.present?
        game = Game.where(name: new_name, edition: new_edition).first_or_create do |g|
          # set minimal defaults so model validations pass
          g.minimum_cards_per_deck = 1
          g.maximum_individual_cards = 1
        end
      end
    end

    # parse content (try JSON first, then XML)
    parsed = nil
    begin
      parsed_json = JSON.parse(content)
      parsed = parsed_json.is_a?(Array) ? parsed_json : (parsed_json['cards'] || parsed_json)
    rescue JSON::ParserError
      # try XML using REXML
      require 'rexml/document'
      doc = REXML::Document.new(content)
      parsed = []
      REXML::XPath.each(doc, '//card') do |node|
        obj = {}
        node.elements.each do |el|
          if el.has_elements?
            # nested data - collect child elements as a hash
            h = {}
            el.elements.each { |c| h[c.name] = c.text }
            obj[el.name] = h
          else
            obj[el.name] = el.text
          end
        end
        parsed << obj
      end
    end

    created = []
    errors = []

    Card.transaction do
      parsed.each_with_index do |entry, idx|
        # entry can be a hash of attributes
        name = entry['name'] || entry[:name]
        data = entry['data'] || entry[:attributes] || {}
        description = entry['description'] || entry[:description]

        # If no game yet, try to use game info from entry (game/edition)
        if game.nil? && (entry['game'] || entry['game_name'] || entry['game_name'])
          gname = entry['game'] || entry['game_name']
          gedition = entry['edition'] || entry['game_edition'] || ''
          game = Game.find_or_create_by(name: gname, edition: gedition)
        end

        unless game
          errors << "Row "+(idx+1).to_s+": no game specified"
          next
        end

        c = Card.new(name: name, description: description, game: game)
        if data.is_a?(Hash)
          c.data = data
        else
          # try to treat remaining keys as data attributes
          if entry.is_a?(Hash)
            data_keys = entry.reject { |k,_| ['name','description','game','game_name','edition','game_edition'].include?(k.to_s) }
            c.data = data_keys
          end
        end

        unless c.save
          errors << "Row "+(idx+1).to_s+": "+c.errors.full_messages.join('; ')
        else
          created << c
        end
      end

      raise ActiveRecord::Rollback if errors.any?
    end

    if errors.any?
      redirect_to cards_path, alert: "Import failed: " + errors.join(' | ')
    else
      redirect_to cards_path, notice: "Imported #{created.size} cards."
    end
  end

  # GET /cards/1/edit
  def edit
  end

  # POST /cards or /cards.json
  def create
    @card = Card.new(card_params)

    respond_to do |format|
      failed_messages = []
      Card.transaction do
        if @card.save
          # Process new uploads
          if params[:card] && params[:card][:new_images]
            params[:card][:new_images].each do |uploaded|
              next unless uploaded.respond_to?(:read)
              img = @card.card_images.build
              img.upload = uploaded
              unless img.save
                failed_messages << img.errors.full_messages.join(', ')
                raise ActiveRecord::Rollback
              end
            end
          end
        end
      end

      if failed_messages.any?
        @card.errors.add(:base, "Image upload failed: #{failed_messages.join('; ')}")
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      elsif @card.persisted?
        format.html { redirect_to @card, notice: "Card was successfully created." }
        format.json { render :show, status: :created, location: @card }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /cards/1 or /cards/1.json
  def update
    respond_to do |format|
      failed_messages = []
      Card.transaction do
        if @card.update(card_params)
          # Process new uploads
          if params[:card] && params[:card][:new_images]
            params[:card][:new_images].each do |uploaded|
              next unless uploaded.respond_to?(:read)
              img = @card.card_images.build
              img.upload = uploaded
              unless img.save
                failed_messages << img.errors.full_messages.join(', ')
                raise ActiveRecord::Rollback
              end
            end
          end

          # Process removals
          if params[:card] && params[:card][:remove_image_ids]
            params[:card][:remove_image_ids].reject(&:blank?).map(&:to_i).each do |id|
              @card.card_images.where(id: id).destroy_all
            end
          end
        end
      end

      if failed_messages.any?
        @card.errors.add(:base, "Image upload failed: #{failed_messages.join('; ')}")
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      elsif @card.errors.any?
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      else
        format.html { redirect_to @card, notice: "Card was successfully updated." }
        format.json { render :show, status: :ok, location: @card }
      end
    end
  end

  # DELETE /cards/1 or /cards/1.json
  def destroy
    begin
      @card.destroy
      respond_to do |format|
        format.html { redirect_to cards_url, notice: "Card was successfully destroyed." }
        format.json { head :no_content }
      end
    rescue ActiveRecord::DeleteRestrictionError => e
      logger.info "Delete restriction preventing card destroy: #{e.message}"
      respond_to do |format|
        format.html { redirect_to card_path(@card), alert: "Cannot delete this card because it's referenced in one or more decks. Remove it from those decks before deleting." }
        format.json { render json: { error: 'delete_restricted', message: e.message }, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def card_params
      cp = params.require(:card).permit(:name, :description, :game_id, data: {}, new_images: [], remove_image_ids: [])

      # Extract and remove upload / removal keys to avoid mass-assigning them to Card
      cp.delete(:new_images)
      cp.delete(:remove_image_ids)

      if cp[:data].is_a?(Hash)
        # Remove placeholder/new attribute entries, blank keys, and keys that contain non-alphanumeric characters
        cp[:data] = cp[:data].transform_keys(&:to_s).reject do |k, _|
          k.strip.empty? || k.match?(/\A(__new__|new_)/i) || !k.match?(/\A[A-Za-z0-9]+\z/)
        end
      end
      cp
    end
end
