module Youtuber
  module Feeds
    class StandardSearchFeed < Feed
      
    
    def base_url
      super << "standardfeeds/"
    end
                
    end
    
  end
  
end

