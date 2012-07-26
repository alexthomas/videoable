
module Youtuber

  class RequestFailed < StandardError; end
  
  class Api
    include Youtuber::Oauth
    
    def initialize *params
        hash_options = params.first
        @consumer_key         = hash_options[:consumer_key]
        @consumer_secret      = hash_options[:consumer_secret]
        @user                 = hash_options[:username]
        @dev_key              = hash_options[:dev_key]
        @client_id            = hash_options[:client_id] || "youtuber"  
        @site                 = hash_options[:site] || "http://vimeo.com"
        @api_endpoint         = hash_options[:api_endpoint] || "http://vimeo.com/api/rest/v2"
        @request_token_path   = hash_options[:request_token_path] || "/oauth/request_token"
        @authorize_path       = hash_options[:authorize_path] || "/oauth/authorize"
        @access_token_path    = hash_options[:access_token_path] || "/oauth/access_token"
        consumer
        unless hash_options[:access_token].nil? && hash_options[:access_token_secret].nil?
          authorize_from_access(hash_options[:access_token], hash_options[:access_token_secret])
          access_token
        end
    end
    
    def make_request(options, authorized)
      if authorized
        raw_response = @oauth_consumer.request(:post, @api_endpoint, get_access_token, {}, options).body
      else
        raw_response = @oauth_consumer.request(:post, @api_endpoint, nil, {}, options).body
      end

      response = JSON.parse(raw_response)
      validate_response! response
      response
    end

    # Raises an exception if the response does contain a +stat+ different from "ok"
    def validate_response!(response)
      raise "empty response" unless response

      status = response["stat"]
      if status and status != "ok"
        error = response["err"]
        if error
          raise RequestFailed, "#{error["code"]}: #{error["msg"]}, explanation: #{error["expl"]}"
        else
          raise RequestFailed, "Error: #{status}, no error message"
        end
      end
    end
    
  end

end