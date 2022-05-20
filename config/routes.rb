Rails.application.routes.draw do
  root to: 'date_ranges#calendar'

  devise_for :users

  get '/calendar', to: 'date_ranges#calendar', as: 'calendar'
  post '/api/date_ranges', to: 'date_ranges#create_json_api', as: 'date_ranges_create_json_api'
  post '/date_ranges', to: 'date_ranges#create', as: 'date_ranges'
end
