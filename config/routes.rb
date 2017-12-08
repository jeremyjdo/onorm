Rails.application.routes.draw do

  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :analyses, :only => [:index, :show, :new, :create]

  get "/team", to: 'pages#team'
  get "/cgu", to: 'pages#cgu'

end
