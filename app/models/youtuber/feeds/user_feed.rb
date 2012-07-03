module Youtuber
  module Feeds
    class UserFeed < Feed
      
      def initialize(params,options = {})
        @url = base_url
        @url << "#{params[:user]}/"
        
        user_playlist = params[:playlist] && params[:playlist] == 'favourites' ? 'favourites' : 'uploads'  
        @url << user_playlist
        @url << build_query_params(to_youtube_params)
        Rails.logger.debug "feed url: #{@url}"
        super params
        
      end
      
      def base_url
        super << "users/"
      end
      
      def parse
        videos = []
        end_parse = false
        fp = Youtuber::FeedParser.new @url
        fp.parse do | parser |
          @offset = parser.response.offset
          @items_per_page ||= parser.response.items_per_page
          parser.response.entries.each do | entry |
            videos << parser.parse_video(entry)

            if Youtuber::Video.video_exists?(videos.last.video_id)
              end_parse = true
              break
            end
            videos.last.save!    
          end
          end_parse = parser.response.next_page.nil? 
          if !end_parse
            Rails.logger.debug "we have a next page and its offset will be #{@offset + @items_per_page}"
          end
        end
        videos
      end
                
    end
    
    def self.perform(url)
      end_parse = false
      fp = Youtuber::FeedParser.new @url
      fp.parse do | parser |
        @offset = parser.response.offset
        @items_per_page ||= parser.response.items_per_page
        parser.response.entries.each do | entry |
          videos << parser.parse_video(entry)
          
          if Youtuber::Video.video_exists?(videos.last.video_id)
            end_parse = true
            break
          end
          videos.last.save!    
        end
        end_parse = parser.response.next_page.nil? 
        if !end_parse
          Rails.logger.debug "we have a next page and its offset will be #{@offset + @items_per_page}"
        end
      end
    end
    
  end
  
end

