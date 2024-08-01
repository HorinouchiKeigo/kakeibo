Rails.application.routes.draw do
  get "sessions/new" => "sessions#new"

  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure' => 'auth0#failure'
  get '/auth/logout' => 'auth0#logout'
  # sessions/newからログアウトすると、なぜかauth/logoutではなくsessions/auth/logoutにリダイレクトされる
  get 'sessions/auth/logout', to: 'auth0#logout'
end
