module Youtuber
  class Uploader
    class UploadError < RuntimeError; end

    CHUNK_SIZE = 2 * 1024 * 1024 # 2 megabytes
    
    attr_reader :io, :size, :filename
    attr_reader :endpoint, :chunks
    attr_reader :vapi
    attr_reader :ticket_id, :video_id
    
    def initialize(consumer_key,consumer_secret,options = {})
      params = {:consumer_key => consumer_key,:consumer_secret => consumer_secret}.merge(options)
      Rails.logger.debug "vimeo params: #{params.inspect}"
      @vapi = Youtuber::Apis::Vimeo::Upload.new(params)
      @chunks = []
    end
    
    def upload(uploadable)
      Resque.enqueue(Uploader, uploadable)
    end

    def self.perform uploadable
      case uploadable
      when File, Tempfile
        upload_file(uploadable)
      when String
        upload_file(File.new(uploadable))
      else
        upload_io(uploadable)
      end
    end
    
    # Uploads an IO to 
    def upload_io(io, size, filename = 'io.data')
      raise "#{io.inspect} must respond to #read" unless io.respond_to?(:read)
      check_quota
      authorize
      t1 = Time.now
      execute
      t2 = Time.now
      delta = t2 - t1
      Rails.logger.debug "time taken to upload video: #{delta}"
      raise UploadError.new, "Validation of chunks failed." unless valid?
      complete

      return video_id
    end

    # Helper for uploading files to 
    def upload_file(file)
      file_path = file.path

      @size     = File.size(file_path)
      @filename = File.basename(file_path)
      @io       = File.open(file_path)
      io.binmode
      Rails.logger.debug "filename of file to upload: #{filename} filepath: #{file_path}"
      upload_io(io, size, filename).tap do
        io.close
      end
    end
      
      
    def generate_upload_io(video_xml, data)
      
      @opts    = { :mime_type => 'video/mp4',
                   :title => '',
                   :description => '',
                   :category => 'People',
                   :keywords => [] }
                   
      post_body = [
        "--#{boundary}\r\n",
        "Content-Type: application/atom+xml; charset=UTF-8\r\n\r\n",
        video_xml,
        "\r\n--#{boundary}\r\n",
        "Content-Type: #{@opts[:mime_type]}\r\nContent-Transfer-Encoding: binary\r\n\r\n",
        data,
        "\r\n--#{boundary}--\r\n",
      ]

      # Use Greedy IO to not be limited by 1K chunks
      Youtuber::GreedyChainIO.new(post_body)
    end
    
    def boundary
      "An43094fu"
    end

    # Checks whether the file can be uploaded.
    def check_quota
      quota = vapi.get_quota
      free  = quota["user"]["upload_space"]["free"].to_i
      Rails.logger.debug "quota: #{quota} free: #{free} size: #{size}"
      raise UploadError.new, "file size exceeds quota. required: #{size}, free: #{free}" if size > free
    end

    # Gets a +ticket_id+ for the upload.
    def authorize
      ticket = vapi.get_ticket
      Rails.logger.debug "ticket: #{ticket.inspect}"
      @ticket_id             = ticket["ticket"]["id"]
      @endpoint       = ticket["ticket"]["endpoint"]
      max_file_size   = ticket["ticket"]["max_file_size"].to_i

      raise UploadError.new, "file was too big: #{size}, maximum: #{max_file_size}" if size > max_file_size
    end

    # Performs the upload.
    def execute
      while (chunk_data = io.read(CHUNK_SIZE)) do
        chunk = Youtuber::Upload::Chunk.new(self, chunk_data)
        chunk.upload
        chunks << chunk
      end
      
    end

    # Tells vimeo that the upload is complete.
    def complete
      @video_id = vapi.complete(ticket_id, filename)
    end

    # Compares Vimeo's chunk list with own chunk list. Returns +true+ if identical.
    def valid?
      received, sent = received_chunk_sizes, sent_chunk_sizes
      sent.all? { |id, size| received[id] == size }
    end

    # Returns a hash of the sent chunks and their respective sizes.
    def sent_chunk_sizes
      Hash[chunks.map { |chunk| [chunk.index.to_s, chunk.size] }]
    end

    # Returns a of Vimeo's received chunks and their respective sizes.
    def received_chunk_sizes
      verification    = vapi.verify_chunks(ticket_id)
      Rails.logger.debug "*****verification array: #{verification.inspect} *******"
      chunk_list      = verification["ticket"]["chunks"]["chunk"]
      chunk_list      = [chunk_list] unless chunk_list.is_a?(Array)
      Hash[chunk_list.map { |chunk| [chunk["id"], chunk["size"].to_i] }]
    end
    
  end
end
