module Youtuber
  
  class VideosController < ::ApplicationController
    
    def index
      Youtuber::Feed.feeds = []
      Youtuber::Feed.add_feed :user => 'livestrong'
      Youtuber::Feed.parse_feeds
      @videos = Video.all
    end
    
    def search
      
    end
        
  end
end