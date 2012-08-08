module Youtuber
  module Apis
    module Vimeo
      
      class Upload < Youtuber::Apis::VimeoApi
        
        create_api_method :check_ticket,
                          "vimeo.videos.upload.checkTicket",
                          :required => [:ticket_id]

        # Complete the upload process.
        create_api_method :complete,
                          "vimeo.videos.upload.complete",
                          :required => [:ticket_id, :filename]

        # Returns an upload ticket.
        create_api_method :get_ticket,
                          "vimeo.videos.upload.getTicket",
                          :optional => [:video_id]

        # Returns the space and HD uploads left for a user.
        create_api_method :get_quota,
                          "vimeo.videos.upload.getQuota"
        Rails.logger.debug "creating method get_quota "
        # Verify that the chunks were uploaded properly.
        create_api_method :verify_chunks,
                          "vimeo.videos.upload.verifyChunks",
                          :required => [:ticket_id]
      end
      
    end
    
  end
end
