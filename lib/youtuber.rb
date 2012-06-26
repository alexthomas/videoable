require "active_support/dependencies"

module Youtuber
  
  mattr_accessor :app_root
  
    # Yield self on setup for nice config blocks
    def self.setup
      yield self
    end

end

#Require our engine
require "youtuber/engine"

require 'orm_adapter/adapters/active_record'
ActiveRecord::Base.extend Devise::Models
