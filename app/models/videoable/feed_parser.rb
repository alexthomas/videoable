module Videoable
  class FeedParser
    attr_reader   :response
    attr_accessor :content, :end_parse
    
    @queue = :feed_queue
    
    def initialize(feed = false)
      @content = (feed =~ URI::regexp(%w(http https)) ? open(feed).read : false)
    rescue OpenURI::HTTPError => e
      raise OpenURI::HTTPError.new(e.io.status[0],e)
    rescue
      @content = false  
    end  
      
    def parse parser
      @response = (@content) ? parser.parse_content(@content) : false
      Rails.logger.debug "response: #{@response.inspect}"
      yield self
    end
  
    def have_content?
      @content
    end
    
    def self.parse_feeds
      Rails.logger.debug "videoable feeds: #{Videoable.video_feeds.inspect}"
      Videoable.video_feeds.each do | feed |
        #feed.parse
        feed.class.enqueue_feed feed
      end
    end
  end
end