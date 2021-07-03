Rails.application.routes.draw do
  resources :games
  resources :decks
  resources :cards
  resources :groups
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
