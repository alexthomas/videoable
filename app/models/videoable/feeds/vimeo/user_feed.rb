module Videoable
  module Feeds
    module Vimeo
      class UserFeed < VimeoFeed
        
        @@max_page = 3
        @queue = :user_feed_queue
        REQUESTS = [:info,:videos,:all_videos,:subscriptions,:channels,:albums,:groups]
        attr_reader :user,:page,:request,:fp
      
        def initialize(params,options = {})
          super params
          @@api = VideoFeed.set_api params,'vimeo','video'
          if @@api.nil?
            @url = base_url
            @page ||= 1
            @request ||= 'videos'
            @url << "#{params[:user]}/#{@request}.json"
            @url << build_query_params(to_vimeo_params)
          end
          
          Rails.logger.debug "feed url: #{@url}"
        
        
        end
      
        def base_url
          super
        end
      
        def parse
         
        end
      
        def self.enqueue_feed feed
          Resque.enqueue(feed.class, feed.user,feed.url,feed.page,feed.items_per_page)
        end
      
        def self.simple_parse url
          videos = []
          end_parse = false
          fp = Videoable::Parser::VimeoParser.new url
        end
        
        def self.advanced_parse user,page,items_per_page
          Rails.logger.debug "we are doing an advanced parse"
          fp = Videoable::Parser::VimeoParser.new
          response = @@api.get_all(user, :page => page, :per_page => items_per_page)
          fp.content = response['videos']['video']
          #Rails.logger.debug "content returned from authenticated call: #{response}"
          #Rails.logger.debug "videos returned from authenticated call: #{fp.content}"
          Rails.logger.debug "total videos: #{response['videos']['total']}"
          Rails.logger.debug "videos pp: #{response['videos']['perpage']}"
          fp.end_parse = true if response['videos']['total'].to_i < response['videos']['perpage'].to_i
          fp
        end
        
        def self.perform(user,url,page,items_per_page)
            videos = []
            fp = (@@api.nil?) ? self.simple_parse(url) : self.advanced_parse(user,page,items_per_page)
            
            fp.parse(fp) do | parser |
              parser.response.entries.each do | entry |
                videos << parser.parse_video(entry)

                if Videoable::Video.video_exists?(videos.last.video_id)
                  end_parse = true
                  break
                end
                videos.last.save!    
              end

            end
            
            Rails.logger.debug "returned videos: #{videos}"
            fp.end_parse = fp.end_parse || page == @@max_page || videos.empty?
            if !fp.end_parse 
              nf = Videoable::Feeds::Vimeo::UserFeed.new(:user => user,:page => (page + 1), :items_per_page => items_per_page)
              self.enqueue_feed nf
            end
          
        end
                
      end
    end
   
  end
  
end

