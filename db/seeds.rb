# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Game.create([
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

User.create([
  {
    :first_name => "Daniel",
    :last_name => "Berger",
    :username => "dberger",
    :password => "asdf"
  }
])
