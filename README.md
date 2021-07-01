## Description
How did you get here? You must be lost.

This is just a pet project where I fumble around trying to create a Rails
project for deckbuilding games like *Magic: The Gathering* or *Ashes: Rise of
the Phoenixborn*. This lets you construct decks from a list of game related
cards and save them for later.

I've no plans for now to publish the thing, it's mostly for my own enjoyment
and gives me a break from the abomination that is the Go programming language.

## Synopsis

```ruby
# First, create some cards
Card.create(:name => "Goblin", :faction => "Red")
Card.create(:name => "Lightning Bolt", :faction => "Red")
Card.create(:name => "Zombie", :faction => "Black")

# Then create a deck
Deck.create(:name => "Black Lightning", :description => "Test Deck")

# Then add some cards to the deck
deck = Deck.first

c1,c2,c3 = Card.all

# Hard way
deck.deck_cards.create(:card => c1, :quantity => 4)
deck.deck_cards.create(:card => c2, :quantity => 2)
deck.deck_cards.create(:card => c3, :quantity => 3)

# Easy way
deck.add(:card => c1, :quantity => 4)
deck.add(:card => c2, :quantity => 2)
deck.add(:card => c3, :quantity => 3)

p d.cards
```

## Other stuff

There's also "games", "users", and "groups" with various attributes.
