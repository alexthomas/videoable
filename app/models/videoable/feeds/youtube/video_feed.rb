module Videoable
  module Feeds
    module Youtube
      class VideoFeed < YoutubeFeed
        
        @queue = :video_feed_queue
        attr_reader :vid,:user,:page,:request,:fp
        
        def initialize(params,options = {})
          @vid = nil
          super params
          params = Videoable.authenticate_params 'youtube', params
          Rails.logger.debug "vid is: #{@vid}"
          @url = base_url << "#{@vid}?v=2" if Videoable::Feed.api.nil?
          Rails.logger.debug "feed url: #{@url}"
        end
    
        def base_url
          super << "videos/"
        end
          
        def self.parse_feed url,vid,save = false
          video = false
          fp = Videoable::Parser::YoutubeParser.new url 
          fp.parse(fp) do | parser |
            parser.response.entries.each do | entry |
              video = parser.parse_video(entry)

              break if Videoable::Video.video_exists?(video)
              video.save! if save
            end

          end
          video
        end
        
        def self.enqueue_feed feed
          Resque.enqueue(feed.class, feed.url,feed.vid)
        end
        
        def self.perform url,vid
          sef.parse_feed url,vid, true
        end
              
      end
    
    end
    
  end
  
end

