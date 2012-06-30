module Youtuber
  class Feed
    include Youtuber::Models.const_get("InstanceMethods")
    
    mattr_accessor :feeds
    @@feeds = []
    STD_FEEDS = [ :top_rated, :top_favorites, :most_viewed, :most_popular,
              :most_recent, :most_discussed, :most_linked, :most_responded,
              :recently_featured, :watch_on_mobile ]
    attr_reader :url, :max_results, :offset, :time
  
    def initialize(*params)
      set_instance_variables(params)
    end
    
    def self.add_feed(params, options={})
      tof = determine_feed_type(params).camelize
      @@feeds <<  "Youtuber::Feeds::#{tof}".constantize.new(params)
    end
    
    
    def base_url
      "http://gdata.youtube.com/feeds/api/"
    end
    
    def build_query_params(params)
      qs = params.to_a.map { | k, v | v.nil? ? nil : "#{Youtuber.esc(k)}=#{Youtuber.esc(v)}" }.compact.sort.join('&')
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