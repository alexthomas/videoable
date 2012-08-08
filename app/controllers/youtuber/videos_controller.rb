module Youtuber
  
  class VideosController < ::ApplicationController
    
    def index
      Youtuber::Feed.feeds = []
      #Youtuber::Feed.add_feed :user => 'unitednations'
      Youtuber::Feed.parse_feeds
      @videos = Video.all
    end
    
    def search
      
    end
    
    def upload
     File.new('movie.mov')
    end
         
  end
end