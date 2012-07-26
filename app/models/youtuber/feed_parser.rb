module Youtuber
  class FeedParser
    attr_reader :response,:content
    
    @queue = :feed_queue
    
    def initialize(feed)
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
  end
end