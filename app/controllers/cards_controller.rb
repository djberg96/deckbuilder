class CardsController < ApplicationController
  before_action :set_card, only: %i[ show edit update destroy ]

  # GET /cards or /cards.json
  def index
    @cards = Card.all
  end

  # GET /cards/1 or /cards/1.json
  def show
  end

  # GET /cards/new
  def new
    @card = Card.new
  end

  # GET /cards/1/edit
  def edit
  end

  # POST /cards or /cards.json
  def create
    @card = Card.new(card_params)

    respond_to do |format|
      if @card.save
        # Process new uploads
        if params[:card] && params[:card][:new_images]
          params[:card][:new_images].each do |uploaded|
            next unless uploaded.respond_to?(:read)
            img = @card.card_images.build(upload: uploaded)
            unless img.save
              @card.errors.add(:base, "Image upload failed: #{img.errors.full_messages.join(', ')}")
            end
          end
        end

        if @card.errors.any?
          format.html { render :new, status: :unprocessable_content }
          format.json { render json: @card.errors, status: :unprocessable_content }
        else
          format.html { redirect_to @card, notice: "Card was successfully created." }
          format.json { render :show, status: :created, location: @card }
        end
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /cards/1 or /cards/1.json
  def update
    respond_to do |format|
      if @card.update(card_params)
        # Process new uploads
        if params[:card] && params[:card][:new_images]
          params[:card][:new_images].each do |uploaded|
            next unless uploaded.respond_to?(:read)
            img = @card.card_images.build(upload: uploaded)
            unless img.save
              @card.errors.add(:base, "Image upload failed: #{img.errors.full_messages.join(', ')}")
            end
          end
        end

        # Process removals
        if params[:card] && params[:card][:remove_image_ids]
          params[:card][:remove_image_ids].reject(&:blank?).map(&:to_i).each do |id|
            @card.card_images.where(id: id).destroy_all
          end
        end

        if @card.errors.any?
          format.html { render :edit, status: :unprocessable_content }
          format.json { render json: @card.errors, status: :unprocessable_content }
        else
          format.html { redirect_to @card, notice: "Card was successfully updated." }
          format.json { render :show, status: :ok, location: @card }
        end
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /cards/1 or /cards/1.json
  def destroy
    @card.destroy
    respond_to do |format|
      format.html { redirect_to cards_url, notice: "Card was successfully destroyed." }
      format.json { head :no_content }
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
