Rails.application.routes.draw do
  get "videos" => "youtuber/videos#index"
  namespace :youtuber do
    resources :authentication
  end
end