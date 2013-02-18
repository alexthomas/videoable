Rails.application.routes.draw do
  get "videos" => "videoable/videos#index"
  get "upload" => "videoable/videos#upload"
  namespace :videoable do
    resources :authentication
  end
end