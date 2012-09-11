module Youtuber
  module Upload
      class Chunk
        MULTIPART_BOUNDARY = "-----------RubyMultipartPost"

        attr_reader :id, :index
        attr_reader :uploader, :vapi
        attr_reader :data, :size

        def initialize(uploader, data)
          @uploader = uploader
          @vapi = uploader.vapi
          @data = data
          @size = data.size
          @index = uploader.chunks.count
        end

        # Performs the upload via Multipart.
        def upload
          endpoint = "#{uploader.endpoint}"

          response = vapi.oauth_consumer.request(:post, endpoint, vapi.get_access_token, {}, {}) do |req|
            req.set_content_type("multipart/form-data", { "boundary" => MULTIPART_BOUNDARY })

            io = StringIO.new(data)
            io.instance_variable_set :"@original_filename", uploader.filename
            def io.original_filename; @original_filename; end
            def io.content_type; "application/octet-stream"; end
            Rails.logger.debug "io original filename #{io.original_filename}"
            Rails.logger.debug "io original filename #{@original_filename}"
            Rails.logger.debug "io #{io.inspect}"
            
            parts = []
            parts << Parts::ParamPart.new(MULTIPART_BOUNDARY, "ticket_id", uploader.ticket_id)
            parts << Parts::ParamPart.new(MULTIPART_BOUNDARY, "chunk_id", index)
            parts << Parts::FilePart.new(MULTIPART_BOUNDARY, "file_data", io)
            parts << Parts::EpiloguePart.new(MULTIPART_BOUNDARY)

            ios                = parts.map{|p| p.to_io }
            req.content_length = parts.inject(0) {|sum,i| sum + i.length }
            req.body_stream    = CompositeReadIO.new(*ios)

            :continue
          end

          # free memory (for big file uploads)
          @data = nil

          @id = response.body
        end
      end
  end
end
  
