require 'resque'

module Youtuber
  class Feed
    include Youtuber::Models.const_get("InstanceMethods")
    
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
      qs = params.to_a.map { | k, v | v.nil? ? nil : "#{Youtuber.esc(k)}=#{Youtuber.esc(v)}" }.compact.sort.join('&')
      "?#{qs}"
    end

    def self.create_feed(params, options={})
      sov = determine_video_source(params)
      tof = "Youtuber::Feeds::#{(sov + "_feed").camelize}".constantize.determine_feed_type(params).camelize
      #tof = determine_feed_type(params).camelize
      "Youtuber::Feeds::#{sov.capitalize}::#{tof}".constantize.new(params)
    end
    
    def self.enqueue_feed feed
      Resque.enqueue(feed.class, feed.url)
    end
    
    protected
      def self.determine_feed_type(feed_type,params)
        feed_type = 'user' if params[:user]
        feed_type << '_feed' 
      end
      
    private
      def self.determine_video_source(params)
        video_source = 'youtube'
        video_source = params[:video_source] if params[:video_source] && !([params[:video_source].to_sym] & Youtuber::VIDEO_SOURCES).empty?
        video_source
      end
    
  end
end