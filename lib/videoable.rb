require "active_support/dependencies"
require 'open-uri'
require 'digest/md5'
require 'nokogiri'
require 'cgi'
require 'oauth'
require 'net/http/post/multipart'

module Videoable
  
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
      @@video_feeds << Videoable::Feed.create_feed(params, options={})
    end
    
    def self.add_oauth(service, params)
      Rails.logger.debug "#{service} oauth is #{params.inspect}"
      @@oauths.store(service,params) if params.is_a?(Hash)
    end
    
    def self.authenticate_params api,params
      return params if params.is_a?(Hash) && (!params[:atoken].nil? && !params[:asecret].nil?)
      params.merge!(Videoable.oauths['vimeo']) if @@oauths.has_key?(api)
      Rails.logger.debug "we have #{api} oauth" if @@oauths.has_key?(api)
      Rails.logger.debug "params in authenticate params #{params.inspect}"
      return params
    end
end

#Require our engine
require "videoable/engine"
require "videoable/models"
require "videoable/models/videoable"
require "videoable/feeds"
require "videoable/oauth"
require "videoable/api"
require "videoable/uploader"
require "videoable/upload/chunk"
require "videoable/chain_io"
require "videoable/apis/vimeo"
require "videoable/apis/vimeo/upload"
require "videoable/apis/vimeo/video"
require "videoable/video_uploader"




ActiveRecord::Base.extend Videoable::Models
ActiveRecord::Base.send :include, Videoable::Models.const_get("InstanceMethods")