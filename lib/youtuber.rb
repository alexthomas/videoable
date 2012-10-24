require "active_support/dependencies"
require 'open-uri'
require 'digest/md5'
require 'nokogiri'
require 'cgi'
require 'oauth'
require 'net/http/post/multipart'

module Youtuber
  
  VIDEO_SOURCES = [:youtube,:vimeo]
  
  mattr_accessor :app_root
  # Keys used when authenticating a user.
  mattr_accessor :video_feeds
  mattr_accessor :oauths
  @@video_feeds = []
  @@oauths = {}
    # Yield self on setup for nice config blocks
    def self.setup
      yield self
    end
  
    def self.esc(s) #:nodoc:
       CGI.escape(s.to_s)
    end
  
    def self.add_feed(params, options={})
      @@video_feeds << Youtuber::Feed.create_feed(params, options={})
    end
    
    def self.add_oauth(service, params)
      Rails.logger.debug "#{service} oauth is #{params.inspect}"
      @@oauths.store(service,params) if params.is_a?(Hash)
    end
    
    def self.authenticate_params api,params
      return params if params.is_a?(Hash) && (!params[:atoken].nil? && !params[:asecret].nil?)
      params.merge!(Youtuber.oauths['vimeo']) if @@oauths.has_key?(api)
      Rails.logger.debug "we have #{api} oauth" if @@oauths.has_key?(api)
      Rails.logger.debug "params in authenticate params #{params.inspect}"
      return params
    end
end

#Require our engine
require "youtuber/engine"
require "youtuber/models"
require "youtuber/models/videoable"
require "youtuber/feeds"
require "youtuber/oauth"
require "youtuber/api"
require "youtuber/uploader"
require "youtuber/upload/chunk"
require "youtuber/chain_io"
require "youtuber/apis/vimeo"
require "youtuber/apis/vimeo/upload"
require "youtuber/apis/vimeo/video"
require "youtuber/video_uploader"




ActiveRecord::Base.extend Youtuber::Models
ActiveRecord::Base.send :include, Youtuber::Models.const_get("InstanceMethods")