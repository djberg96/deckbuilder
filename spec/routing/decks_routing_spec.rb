require "rails_helper"

RSpec.describe DecksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/decks").to route_to("decks#index")
    end

    it "routes to #new" do
      expect(get: "/decks/new").to route_to("decks#new")
    end

    it "routes to #show" do
      expect(get: "/decks/1").to route_to("decks#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/decks/1/edit").to route_to("decks#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/decks").to route_to("decks#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/decks/1").to route_to("decks#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/decks/1").to route_to("decks#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/decks/1").to route_to("decks#destroy", id: "1")
    end
  end
end
