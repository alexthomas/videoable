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
      
      protected
        
       def self.authenticated_access? params
          params.is_a?(Hash) && (!params[:atoken].nil? && !params[:asecret].nil?) ? true : false
       end
      
        
       def self.set_vapi params
         #@@vapi = Youtuber::Feeds::VimeoFeed.authenticated_access?(params) ? Youtuber::Apis::Vimeo::Video.new(params) : nil
         @@vapi = Youtuber::Apis::Vimeo::Video.new(Youtuber.authenticate_params('vimeo', params))
       end
       
       def self.have_vapi?
         @@vapi.nil?
       end
       
      private 
        def self.determine_feed_type(params)
          super 'video',params
        end
    end
  end
end