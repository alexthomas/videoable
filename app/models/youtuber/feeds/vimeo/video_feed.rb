module Youtuber
  module Feeds
    module Vimeo
      class VideoFeed < VimeoFeed
        
        attr_accessor :vid
        attr_reader :user,:page,:request,:fp
        @queue = :video_feed_queue
        
        def initialize(params,options = {})
          @vid = nil
          super params
          params = Youtuber::Feeds::VimeoFeed.authenticate_params params
          Rails.logger.debug "vid is: #{@vid}"
          @@vapi = Youtuber::Feeds::VimeoFeed.authenticated_access?(params) ? Youtuber::Apis::Vimeo::Video.new(params) : nil
          @url = base_url << "#{@vid}.json" if @@vapi.nil?
          Rails.logger.debug "feed url: #{@url}"
        
        
        end
        
        def base_url
          super << "video/"
        end
        
        def info
          base_url << "video/#{@vid}.json"
        end
        
        def self.enqueue_feed feed
          Resque.enqueue(feed.class, feed.url,feed.vid)
        end
        
        def self.advanced_parse vid
          Rails.logger.debug "we are doing an advanced parse with a vid of #{vid}"
          fp = Youtuber::Parser::VimeoParser.new
          response = @@vapi.get_info vid
          Rails.logger.debug "content returned from authenticated call: #{response}"
          fp.content = response['video']
          
          Rails.logger.debug "videos returned from authenticated call: #{fp.content}"
          fp
        end
        
        def self.perform url,vid
          videos = []
          fp = (@@vapi.nil?) ? Youtuber::Parser::VimeoParser.new(url) : self.advanced_parse(vid)
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
