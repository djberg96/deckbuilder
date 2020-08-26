```
# First, create some cards

* Card.create(:name => "Goblin", :faction => "Red")
* Card.create(:name => "Lightning Bolt", :faction => "Red")
* Card.create(:name => "Zombie", :faction => "Black")

# Then create a deck
* Deck.create(:name => "Black Lightning", :description => "Test Deck")

# Then add some cards to the deck
* deck = Deck.first

* c1,c2,c3 = Card.all

# Hard way
* deck.deck_cards.create(:card => c1, :quantity => 4)
* deck.deck_cards.create(:card => c2, :quantity => 2)
* deck.deck_cards.create(:card => c3, :quantity => 3)

# Easy way
* deck.add(:card => c1, :quantity => 4)
* deck.add(:card => c2, :quantity => 2)
* deck.add(:card => c3, :quantity => 3)

* p d.cards
```
