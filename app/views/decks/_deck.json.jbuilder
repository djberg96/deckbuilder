json.extract! deck, :id, :name, :description, :private, :created_at, :updated_at

if deck.user
  json.owner do
    json.extract! deck.user, :id, :username
  end
end

if deck.game
  json.game do
    json.extract! deck.game, :id, :name, :edition
  end
end

json.deck_cards deck.deck_cards do |dc|
  json.extract! dc, :id, :quantity
  json.card do
    json.extract! dc.card, :id, :name
  end
end

json.url deck_url(deck, format: :json)
