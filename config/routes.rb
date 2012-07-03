Rails.application.routes.draw do
  get "videos" => "youtuber/videos#index"
  #mount Resque::Server, :at => "/resque"
end