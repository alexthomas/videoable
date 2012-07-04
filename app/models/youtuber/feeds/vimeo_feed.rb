module Youtuber
  module Feeds
    class VimeoFeed < Feed


      def base_url
        "http://http://vimeo.com/api/v2/"
      end

      def to_vimeo_params
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
          super params
        end
    end
  end
end