module Youtuber
  module Feeds
    module Vimeo
      class VideoFeed < VimeoFeed
        
        attr_accessor :vid
        @queue = :video_feed_queue
        
        def initialize(params,options = {})
          @vid = nil
          super params
          params = Youtuber::Feeds::VimeoFeed.authenticate_params params
          @@vapi = Youtuber::Feeds::VimeoFeed.authenticated_access?(params) ? Youtuber::Apis::Vimeo::Video.new(params) : nil
          
          Rails.logger.debug "options in video feed: #{options.inspect}"
          Rails.logger.debug "params in video feed: #{params.inspect}"
          Rails.logger.debug "vapi in video feed: #{@@vapi.inspect}"
          @url = base_url << "#{@vid}.json" if @@vapi.nil?
          Rails.logger.debug "feed url: #{@url}"
        
        
        end
        
        def base_url
          super << "video/"
        end
        
        def info
          base_url << "video/#{@vid}.json"
        end
        
        def self.perform url
          videos = []
          fp = Youtuber::Parser::VimeoParser.new url
          
          fp.parse(fp) do | parser |
            parser.response.entries.each do | entry |
              videos << parser.parse_video(entry)

              if Youtuber::Video.video_exists?(videos.last.video_id)
                end_parse = true
                break
              end
              videos.last.save!    
            end

          end
        end
        
      end
    end
    
  end
  
end
