module Youtuber
  module Feeds
    class VideoSearchFeed < Feed

    def base_url
      super << "videos"
    end
                
    end
    
  end
  
end

