require "active_support/dependencies"
require 'open-uri'
require 'digest/md5'
require 'nokogiri'
require "cgi"

module Youtuber
  
  mattr_accessor :app_root
  # Keys used when authenticating a user.
  mattr_accessor :video_feeds
  @@video_feeds = []
    # Yield self on setup for nice config blocks
    def self.setup
      yield self
    end
  
    def self.esc(s) #:nodoc:
       CGI.escape(s.to_s)
    end
  
    def self.add_feed(params, options={})
      @@video_feeds << Youtuber::Feed.add_feed(params, options={})
    end
end

#Require our engine
require "youtuber/engine"
require "youtuber/models"
require "youtuber/feeds"


ActiveRecord::Base.extend Youtuber::Models
ActiveRecord::Base.send :include, Youtuber::Models.const_get("InstanceMethods")