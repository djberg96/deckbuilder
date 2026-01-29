require 'rails_helper'

RSpec.describe "Cards#destroy", type: :request do
  let!(:card) { create(:card) }

  context "when deletion is restricted by dependent records" do
    before do
      allow_any_instance_of(Card).to receive(:destroy).and_raise(ActiveRecord::DeleteRestrictionError.new("Referenced by deck_cards"))
    end

    it "redirects back with a flash alert for HTML requests" do
      delete card_path(card)
      expect(response).to redirect_to(card_path(card))
      follow_redirect!
      expect(response.body).to include("Cannot delete this card because it's referenced in one or more decks")
    end

    it "returns 422 JSON error for JSON requests" do
      delete card_path(card), headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('delete_restricted')
    end
  end
end
