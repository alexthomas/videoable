module Youtuber
  module Feeds
    module Vimeo
      class VideoFeed < VimeoFeed
        
        attr_reader :vid,:user,:page,:request,:fp
        @queue = :video_feed_queue
        
        def initialize(params,options = {})
          @vid = nil
          super params
          params = Youtuber.authenticate_params 'vimeo', params
          Rails.logger.debug "vid is: #{@vid}"
          @@vapi = VideoFeed.set_vapi params
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
        
        def self.parse_feed url,vid,save = false
          video = false
          fp = (@@vapi.nil?) ? Youtuber::Parser::VimeoParser.new(url) : self.advanced_parse(vid)
          fp.parse(fp) do | parser |
            parser.response.entries.each do | entry |
              video = parser.parse_video(entry)

              break if Youtuber::Video.video_exists?(video)
              video.save! if save
            end

          end
          video
        end
        
        def self.perform url,vid
          self.parse_feed url,vid,true
        end
        
      end
    end
    
  end
  
end
