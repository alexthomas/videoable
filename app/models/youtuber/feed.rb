require 'resque'

module Youtuber
  class Feed
    include Youtuber::Models.const_get("InstanceMethods")
    
    mattr_accessor :feeds
    STD_FEEDS = [ :top_rated, :top_favorites, :most_viewed, :most_popular,
              :most_recent, :most_discussed, :most_linked, :most_responded,
              :recently_featured, :watch_on_mobile ]
              
    attr_reader :feed_id,:url,:updated_at,:total_result_count,:offset,:items_per_page
    
    def initialize(*params)
      set_instance_variables(*params)
    end
    
    def self.add_feed(params, options={})
      tof = determine_feed_type(params).camelize
      "Youtuber::Feeds::#{tof}".constantize.new(params)
    end
    
    def self.parse_feeds
      Rails.logger.debug "youtuber feeds: #{Youtuber.video_feeds.inspect}"
      Youtuber.video_feeds.each do | feed |
        #feed.parse
        feed.class.enqueue_feed feed
      end
    end
    
    def self.enqueue_feed feed
      Resque.enqueue(feed.class, feed.url)
    end
    
    def base_url
      "http://gdata.youtube.com/feeds/api/"
    end
    
    def build_query_params(params)
      qs = params.to_a.map { | k, v | v.nil? ? nil : "#{Youtuber.esc(k)}=#{Youtuber.esc(v)}" }.compact.sort.join('&')
      "?#{qs}"
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
        feed_type = 'user' if params[:user]
        feed_type = 'standard_search' if !(params.keys & STD_FEEDS).empty?
        feed_type << '_feed' 
      end
    
  end
end