require "active_support/dependencies"
require 'open-uri'
require 'digest/md5'
require 'nokogiri'

module Youtuber
  
  mattr_accessor :app_root
  
    # Yield self on setup for nice config blocks
    def self.setup
      yield self
    end
    
    def self.esc(s) #:nodoc:
       CGI.escape(s.to_s)
    end
end

#Require our engine
require "youtuber/engine"
require "youtuber/models"
require "youtuber/feeds"


ActiveRecord::Base.extend Youtuber::Models
ActiveRecord::Base.send :include, Youtuber::Models.const_get("InstanceMethods")