module Youtuber
  
  class VideosController < ::ApplicationController
    
    def index
      @videos = Video.all
    end
    
    def search
      
    end
        
  end
end