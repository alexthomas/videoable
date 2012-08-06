module Youtuber
  class Uploader
    
    def generate_upload_io(video_xml, data)
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
    
  end
end
