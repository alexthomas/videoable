module Videoable
  module Feeds
    module Youtube
      class UserFeed < YoutubeFeed
      
        @queue = :user_feed_queue
      
        attr_reader :user
      
        def initialize(params,options = {})
          super params
          @url = base_url
          @url << "#{params[:user]}/"
        
          user_playlist = params[:playlist] && params[:playlist] == 'favourites' ? 'favourites' : 'uploads'  
          @url << user_playlist
          @url << build_query_params(to_youtube_params)
          Rails.logger.debug "feed url: #{@url}"
        
        
        end
      
        def base_url
          super << "users/"
        end
      
        def parse
         
        end
      
        def self.enqueue_feed feed
          Resque.enqueue(feed.class, feed.user,feed.url)
        end
      
        def self.perform(user,url)
          videos = []
          end_parse = false
          fp = Videoable::Parser::YoutubeParser.new url
          fp.parse(fp) do | parser |
            parser.response.entries.each do | entry |
              videos << parser.parse_video(entry)

              if Videoable::Video.video_exists?(videos.last.video_id)
                end_parse = true
                break
              end
              videos.last.save!    
            end
            end_parse = parser.response.next_page.nil? 
            if !end_parse
              nf = Videoable::Feeds::Youtube::UserFeed.new(:user => user,:offset => parser.response.next_offset, :items_per_page => parser.response.items_per_page)
              Rails.logger.debug "next feed url #{nf.url}"
              #self.enqueue_feed nf
            end
          end
        end
                
      end
    end
   
  end
  
end

