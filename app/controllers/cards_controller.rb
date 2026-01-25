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
    @card = Card.new(card_params.except(:attributes))
    @card.data = process_attributes(params[:card][:attributes]) if params[:card][:attributes]

    respond_to do |format|
      if @card.save
        format.html { redirect_to @card, notice: "Card was successfully created." }
        format.json { render :show, status: :created, location: @card }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cards/1 or /cards/1.json
  def update
    @card.assign_attributes(card_params.except(:attributes))
    @card.data = process_attributes(params[:card][:attributes]) if params[:card][:attributes]

    respond_to do |format|
      if @card.save
        format.html { redirect_to @card, notice: "Card was successfully updated." }
        format.json { render :show, status: :ok, location: @card }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @card.errors, status: :unprocessable_entity }
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
      params.require(:card).permit(:name, :description, :data, :game_id, :image_file, :image_content_type, :image_filename, attributes: [:key, :value])
    end

    def process_attributes(attributes_params)
      return {} unless attributes_params
      attributes_hash = {}
      attributes_params.each do |attr|
        next if attr[:key].blank?
        attributes_hash[attr[:key]] = attr[:value]
      end
      attributes_hash
    end
end
