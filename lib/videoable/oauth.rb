module Videoable
  module Oauth
    
    attr_reader :atoken, :asecret
    attr_reader :oauth_consumer
    
    def consumer
      @oauth_consumer ||= OAuth::Consumer.new(@consumer_key,@consumer_secret,{
        :site => @site,
        :request_token_path=>@request_token_path,
        :authorize_path=> @authorize_path,
        :access_token_path=>@access_token_path})
    end
    
    def authorize_url(permission = "delete")
      get_request_token.authorize_url :permission => permission
    end

    def get_request_token
      @request_token ||= consumer.get_request_token :scheme => :header
    end
    
    def access_token
      Rails.logger.debug "creating access token"
      @access_token = OAuth::AccessToken.new(consumer, @atoken, @asecret)
    end

    def authorize_from_request(oauth_token=nil, oauth_secret=nil, oauth_verifier=nil)
      get_access_token(oauth_token, oauth_secret, oauth_verifier)
      @atoken,@asecret = @access_token.token, @access_token.secret
    end
    
    def get_access_token(oauth_token=nil, oauth_secret=nil, oauth_verifier=nil)
       @access_token ? Rails.logger.debug("have access token") : Rails.logger.debug("don't have access token")
       @access_token ||= OAuth::RequestToken.new(consumer, oauth_token, oauth_secret).get_access_token :oauth_verifier => oauth_verifier
    end
    
    def authorize_from_access(atoken,asecret)
      @atoken,@asecret = atoken, asecret
    end
   
    def authenticated
      
    end
    
  end

end