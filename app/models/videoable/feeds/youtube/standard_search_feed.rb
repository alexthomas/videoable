module Videoable
  module Feeds
    module Youtube
      class StandardSearchFeed < YoutubeFeed
      
    
        def base_url
          super << "standardfeeds/"
        end
                
      end
    
    end
    
  end
  
end

