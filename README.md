# First, create some cards

* Card.create(:name => "Goblin", :faction => "Red")
* Card.create(:name => "Lightning Bolt", :faction => "Red")
* Card.create(:name => "Zombie", :faction => "Black")

# Then create a deck
* Deck.create(:name => "Black Lightning", :description => "Test Deck")

# Then add some cards to the deck
* d = Deck.first

* c1,c2,c3 = Card.all
* d.deck_cards.create(:card => c1, :quantity => 4)
* d.deck_cards.create(:card => c2, :quantity => 2)
* d.deck_cards.create(:card => c3, :quantity => 3)

* d.cards
