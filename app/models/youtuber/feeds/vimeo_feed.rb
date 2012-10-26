module Youtuber
  module Feeds
    class VimeoFeed < Feed

      RESPONSE_FORMATS = [:json,:xml]
      
      attr_reader :page
      
      def base_url
        "http://vimeo.com/api/v2/"
      end

      def to_vimeo_params
        {
          'page' => @page
        }
      end
       
      private 
        def self.determine_feed_type(params)
          super 'video',params
        end
    end
  end
end