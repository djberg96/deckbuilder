begin
  require 'prawn'
  require 'prawn-table'
rescue LoadError => e
  Rails.logger.error "PDF generation gem missing: #{e.message}"
end

class DecksController < ApplicationController
  before_action :set_deck, only: %i[ show edit update destroy ]

  # GET /decks or /decks.json
  def index
    @games = Game.order(:name)
    @owners = User.order(:username)

    # base query includes associations for efficiency
    decks_scope = Deck.includes(:game, :user).order(:name)

    if params[:filter_column].present? && params[:filter_value].present?
      case params[:filter_column]
      when 'game'
        decks_scope = decks_scope.where(game_deck: { game_id: params[:filter_value] }).references(:game_deck)
      when 'owner'
        decks_scope = decks_scope.where(user_id: params[:filter_value])
      end
    end

    # Optionally hide private decks owned by others
    if params[:hide_private_others].present? && @user
      decks_scope = decks_scope.where('NOT (private = ? AND user_id != ?)', true, @user.id)
    end

    @decks = decks_scope
  end

  # GET /decks/1 or /decks/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :show }
      format.xml do
        render xml: @deck.to_xml(
          :include => {
            :game => { :only => [:id, :name, :edition] },
            :deck_cards => { :include => { :card => { :only => [:id, :name] } }, :only => [:id, :quantity] }
          },
          :except => [:created_at, :updated_at]
        )
      end
      format.pdf do
        # Build a simple, nicely formatted PDF using Prawn
        pdf = Prawn::Document.new(page_size: 'A4')
        pdf.font_size 18
        pdf.text "Deck: #{@deck.name}", style: :bold
        pdf.move_down 6
        pdf.font_size 12
        pdf.text "Owner: #{@deck.user&.username || 'Unknown'}"
        if @deck.game
          pdf.text "Game: #{@deck.game.name}#{@deck.game.edition.present? ? " (#{@deck.game.edition})" : ''}"
        end
        pdf.move_down 12
        pdf.text "Cards", style: :bold
        pdf.move_down 6
        table_data = [["Card", "Quantity"]]
        @deck.deck_cards.includes(:card).each do |dc|
          table_data << [dc.card.name, dc.quantity.to_s]
        end
        pdf.table(table_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          columns(1).align = :right
        end

        send_data pdf.render, filename: "#{@deck.name.parameterize}-deck.pdf", type: 'application/pdf', disposition: 'attachment'
      end
    end
  end

  # GET /decks/new
  def new
    @deck = Deck.new
    @deck.build_game_deck
    @games = Game.all
    @cards_by_game = Card.all.map { |c| {id: c.id, name: c.name, game_id: c.game_id} }
  end

  # GET /decks/1/edit
  def edit
    # Ensure the deck has a game_deck association so the edit form's game select
    # contains a value and the cards UI (Add/Delete) is shown.
    @deck.build_game_deck unless @deck.game_deck

    @games = Game.all
    @cards_by_game = Card.order(:name).map { |c| {id: c.id, name: c.name, game_id: c.game_id} }
  end

  # POST /decks or /decks.json
  def create
    @deck = Deck.new(deck_params)
    @deck.user_id = session[:user_id]

    respond_to do |format|
      if @deck.save
        format.html { redirect_to @deck, notice: "Deck was successfully created." }
        format.json { render :show, status: :created, location: @deck }
      else
        @games = Game.all
        @cards_by_game = Card.order(:name).map { |c| {id: c.id, name: c.name, game_id: c.game_id} }
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @deck.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /decks/1 or /decks/1.json
  def update
    @games = Game.all
    @cards_by_game = Card.order(:name).map { |c| {id: c.id, name: c.name, game_id: c.game_id} }
    respond_to do |format|
      if @deck.update(deck_params)
        format.html { redirect_to @deck, notice: "Deck was successfully updated." }
        format.json { render :show, status: :ok, location: @deck }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @deck.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /decks/1 or /decks/1.json
  def destroy
    @deck.destroy
    respond_to do |format|
      format.html { redirect_to decks_url, notice: "Deck '#{@deck.name}' was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deck
      @deck = Deck.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def deck_params
      params.require(:deck).permit(:deck, :name, :description, :private, game_deck_attributes: [:id, :game_id], deck_cards_attributes: [:id, :card_id, :quantity, :_destroy])
    end
end
