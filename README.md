## Description
How did you get here? You must be lost.

This is just a pet project where I fumble around trying to create a Rails
project for deckbuilding games like *Magic: The Gathering* or *Ashes: Rise of
the Phoenixborn*. This lets you construct decks from a list of game related
cards and save them for later.

I've no plans for now to publish the thing, it's mostly for my own enjoyment
and gives me a break from the abomination that is the Go programming language.

## Synopsis

Assuming you want to do everything in the console:

```ruby
# First, create a game with some basic deck construction rules
magic = Game.create(
  :name                     => "Magic: The Gathering",
  :description              => "Cardboard crack",
  :maximum_individual_cards => 4,
  :minimum_cards_per_deck   => 60
)

# Then, create some cards, and associate them with the game
Card.create(:name => "Goblin", :faction => "Red", :game => magic)
Card.create(:name => "Lightning Bolt", :faction => "Red", :game => magic)
Card.create(:name => "Zombie", :faction => "Black", :game => magic)

# Then create a deck, and associate it with your account
user = User.find_by(:username => "noobcrusher")
Deck.create(:name => "Black Lightning", :description => "Test Deck", :user => user)

# Then add some cards to the deck
deck = Deck.first

c1,c2,c3 = Card.all

deck.add(:card => c1, :quantity => 4)
deck.add(:card => c2, :quantity => 2)
deck.add(:card => c3, :quantity => 3)

p d.cards
```

## Other stuff

There's also a Group model with various attributes that you can use
to form groups of users, e.g. your local gaming club.
