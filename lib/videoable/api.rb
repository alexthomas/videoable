
module Videoable

  class RequestFailed < StandardError; end
  
  class Api
    include Videoable::Oauth
    
    def initialize params = {}
        @api_type             = params[:api_type] || "vimeo"
        params = Videoable.authenticate_params @api_type, params
        @consumer_key         = params[:consumer_key]
        @consumer_secret      = params[:consumer_secret]
        @user                 = params[:username]
        @dev_key              = params[:dev_key]
        @client_id            = params[:client_id] || "videoable"  
        @site                 = params[:site] || "http://vimeo.com"
        @api_endpoint         = params[:api_endpoint] || "http://vimeo.com/api/rest/v2"
        @request_token_path   = params[:request_token_path] || "/oauth/request_token"
        @authorize_path       = params[:authorize_path] || "/oauth/authorize"
        @access_token_path    = params[:access_token_path] || "/oauth/access_token"
        consumer
        unless params[:atoken].nil? && params[:asecret].nil?
          authorize_from_access(params[:atoken], params[:asecret])
          access_token
          Rails.logger.debug "atoken #{atoken} and asecret #{asecret}"
        else
          Rails.logger.debug "atoken #{atoken} and asecret #{asecret}are nil"
        end
    end
    
    def authenticated_access?
        !@access_token.nil?
     end
      
     def self.set_api params, api_type, api_endpoint
       @@api = self.authenticated_access?(params) ? "Videoable::Apis::#{api_type.capitalize}::#{api_endpoint.capitalize}".constantize.new(params) : nil
     end
     
    def make_request(options, require_auth)
      if require_auth
        Rails.logger.debug "api call requires authorisation: #{@api_endpoint}"
        raw_response = consumer.request(:post, @api_endpoint, get_access_token, {}, options).body
      else
        Rails.logger.debug "authorized api endpoing: #{@api_endpoint}"
        raw_response = consumer.request(:post, @api_endpoint, nil, {}, options).body
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