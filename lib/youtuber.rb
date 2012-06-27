require "active_support/dependencies"

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

ActiveRecord::Base.extend Youtuber::Models
ActiveRecord::Base.send :include, Youtuber::Models.const_get("InstanceMethods")