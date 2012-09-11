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
      
        def self.authenticate_params params
          return params if params.is_a?(Hash) && (!params[:atoken].nil? && !params[:asecret].nil?)
          params.merge(Youtuber.oauths['vimeo']) if Youtuber.oauths.has_key?('vimeo')
          return params
        end
        
       def self.authenticated_access? params
          params.is_a?(Hash) && (!params[:atoken].nil? && !params[:asecret].nil?) ? true : false
       end
        
      private 
        def self.determine_feed_type(params)
          super false,params
        end
    end
  end
end