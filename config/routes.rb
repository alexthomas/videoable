Rails.application.routes.draw do
  get "videos" => "youtuber/videos#index"
end