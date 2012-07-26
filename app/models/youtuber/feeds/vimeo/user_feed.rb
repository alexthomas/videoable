module Youtuber
  module Feeds
    module Vimeo
      class UserFeed < VimeoFeed
        
        @@max_page = 3
        @queue = :user_feed_queue
        REQUESTS = [:info,:videos,:all_videos,:subscriptions,:channels,:albums,:groups]
        attr_reader :user,:page,:request
      
        def initialize(params,options = {})
          super params
          @url = base_url
          @page ||= 1
          @request ||= 'videos'
          @url << "#{params[:user]}/#{@request}.json"
          @url << build_query_params(to_vimeo_params)
          Rails.logger.debug "feed url: #{@url}"
        
        
        end
      
        def base_url
          super
        end
      
        def parse
         
        end
      
        def self.enqueue_feed feed
          Resque.enqueue(feed.class, feed.user,feed.url,feed.page)
        end
      
        def self.perform(user,url,page)
          videos = []
          end_parse = false
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
            end_parse = page == @@max_page || parser.response.entries.empty?
            if !end_parse 
              nf = Youtuber::Feeds::Vimeo::UserFeed.new(:user => user,:page => (page + 1), :items_per_page => parser.response.items_per_page)
              Rails.logger.debug "next feed url #{nf.url}"
              self.enqueue_feed nf
            end
          end
        end
                
      end
    end
   
  end
  
end

