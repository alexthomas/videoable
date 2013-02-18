module Videoable
  module Feeds
    module Youtube
      class VideoSearchFeed < YoutubeFeed

        def base_url
          super << "videos"
        end
                
      end
    end
    
  end
  
end

