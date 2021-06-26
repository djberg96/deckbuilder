class CardsController < ApplicationController
  def index
    @cards = Card.all
  end

  def show
    @card = Card.find(params[:id])

    respond_to do |format|
      format.html
      format.json
    end
  end
end
