# Run db:seed or db:setup to add these.
Game.create!([
  {
    :name                     => "Magic: The Gathering",
    :description              => "Cardboard crack",
    :minimum_cards_per_deck   => 60,
    :maximum_individual_cards => 4
  },
  {
    :name                     => "Android: Netrunner",
    :description              => "Fantasy Flight remake of original Netrunner",
    :minimum_cards_per_deck   => 30,
    :maximum_individual_cards => 3
  }
])

User.create!([
  {
    :first_name => "Daniel",
    :last_name  => "Berger",
    :password   => "secret1",
    :username   => "dberger"
  },
  {
    :first_name => "John",
    :last_name  => "Smith",
    :password   => "secret2",
    :username   => "jsmith"
  }
])

Group.create!([
  {
    :name => "Test Group 1"
  },
  {
    :name => "Test Group 2"
  }
])
