Rails.application.routes.draw do
  get "videos" => "youtuber/videos#index"
  get "upload" => "youtuber/videos#upload"
  namespace :youtuber do
    resources :authentication
  end
end