require 'resque'

module Videoable
  class Feed
    include Videoable::Models.const_get("InstanceMethods")
    
    class << self
      attr_reader :api
    end
            
    attr_reader :feed_id,:url,:updated_at,:total_result_count,:offset,:items_per_page
    
    def initialize(params)
      Rails.logger.debug "feed params #{params}"
      set_instance_variables(params)
      @items_per_page ||= 20
    end

    def build_query_params(params)
      qs = params.to_a.map { | k, v | v.nil? ? nil : "#{Videoable.esc(k)}=#{Videoable.esc(v)}" }.compact.sort.join('&')
      "?#{qs}"
    end

    def self.create_feed(params, options={})
      sov = determine_video_source(params)
      tof = "Videoable::Feeds::#{(sov + "_feed").camelize}".constantize.determine_feed_type(params).camelize
      #tof = determine_feed_type(params).camelize
      "Videoable::Feeds::#{sov.capitalize}::#{tof}".constantize.new(params)
    end
    
    def self.enqueue_feed feed
      Resque.enqueue(feed.class, feed.url)
    end
    
    protected
      def self.determine_feed_type(feed_type,params)
        feed_type = 'user' if params[:user]
        feed_type << '_feed' 
      end

       def self.set_api params, api_type, api_endpoint
         api = "Videoable::Apis::#{api_type.capitalize}::#{api_endpoint.capitalize}".constantize.new(params)
         @@api = api.authenticated_access? ? api : nil
       end
       
       def self.have_api?
         @@api.nil?
       end
      
    private
      def self.determine_video_source(params)
        video_source = 'youtube'
        video_source = params[:video_source] if params[:video_source] && !([params[:video_source].to_sym] & Videoable::VIDEO_SOURCES).empty?
        video_source
      end
    
  end
end