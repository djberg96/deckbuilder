Rails.application.routes.draw do
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  root 'decks#index'

  resources :games
  resources :decks
  resources :cards
  resources :groups
  resources :users
end
