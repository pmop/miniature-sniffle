Rails.application.routes.draw do
  root to: 'date_ranges#calendar'

  resources :date_ranges
  devise_for :users

  get '/calendar', to: 'date_ranges#calendar', as: 'calendar'
end
