module Videoable
  
  class AuthenticationController < ::ApplicationController
    
    def new
      vapi = Videoable::Apis::Vimeo.new(:consumer_key => 'd1831f1350518e6125032ea1fd6fa7ee7b7567c5',:consumer_secret => '4b7f5afe3f4b657dccd358e33fa7cb914aa102bf')
      request_token = vapi.get_request_token
      session[:oauth_secret] = request_token.secret 
      redirect_to vapi.authorize_url
    end
    
        
  end
end