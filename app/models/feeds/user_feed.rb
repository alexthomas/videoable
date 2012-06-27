module Youtuber
  module Feeds
    class UserFeed < Feed

    def base_url
      super << "users/"
    end
                
    end
    
  end
  
end

