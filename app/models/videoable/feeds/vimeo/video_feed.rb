module Videoable
  module Feeds
    module Vimeo
      class VideoFeed < VimeoFeed
        
        attr_reader :vid,:user,:page,:request,:fp
        @queue = :video_feed_queue
        
        def initialize(params,options = {})
          @vid = nil
          super params
          
          Rails.logger.debug "vid is: #{@vid}"
          @@api = VideoFeed.set_api params, 'vimeo', 'video'
          @url = base_url << "#{@vid}.json" if @@api.nil?
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
          fp = Videoable::Parser::VimeoParser.new
          response = @@api.get_info vid
          Rails.logger.debug "content returned from authenticated call: #{response}"
          fp.content = response['video']
          
          Rails.logger.debug "videos returned from authenticated call: #{fp.content}"
          fp
        end
        
        def self.parse_feed url,vid,save = false
          video = false
          fp = (@@api.nil?) ? Videoable::Parser::VimeoParser.new(url) : self.advanced_parse(vid)
          fp.parse(fp) do | parser |
            parser.response.entries.each do | entry |
              video = parser.parse_video(entry)

              break if Videoable::Video.video_exists?(video)
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
