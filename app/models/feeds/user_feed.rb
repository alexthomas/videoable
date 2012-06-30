module Youtuber
  module Feeds
    class UserFeed < Feed
      
      def initialize(params,options = {})
        @url = base_url
        @url << "#{params[:user]}/"
        user_playlist = params[:playlist] && params[:playlist] == 'favourites' ? 'favourites' : 'uploads'  
        @url << user_playlist
        super params
        
      end
      
      def base_url
        super << "users/"
      end
      
      def parse
        videos = []
        fp = Youtuber::FeedParser.new @url
        fp.parse do | parser |
          parser.entries.each do | entry |
            videos <<  parser.parse_video(entry)
          end
        end
        videos
      end
                
    end
    
  end
  
end

