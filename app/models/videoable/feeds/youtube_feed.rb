module Videoable
  module Feeds
    class YoutubeFeed < Feed
  
      STD_FEEDS = [ :top_rated, :top_favorites, :most_viewed, :most_popular,
                :most_recent, :most_discussed, :most_linked, :most_responded,
                :recently_featured, :watch_on_mobile ]

      def base_url
        "http://gdata.youtube.com/feeds/api/"
      end

      def to_youtube_params
        {
          'max-results' => @items_per_page,
          'orderby' => @order_by,
          'start-index' => @offset,
          'v' => 2
        }
      end
      
      private 
        def self.determine_feed_type(params)
          feed_type = 'video_search'
          feed_type = 'standard_search' if !(params.keys & STD_FEEDS).empty?
          super feed_type, params
        end
    end
  end
end