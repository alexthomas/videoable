module Youtuber
  class Video < ActiveRecord::Base
    include Youtuber::Models.const_get("InstanceMethods")
    set_table_name "yt_videos"
    
    YOUTUBE_REGEXP  = '^(?:https?:\/\/)?(?:[0-9A-Z-]+\.)?(youtu\.be\/|youtube\.com)'
    VIMEO_REGEXP    = '^(?:https?:\/\/)?(?:[0-9A-Z-]+\.)?(vimeo.com)'
    VID_REGEXP      = '^(?:https?:\/\/)?(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube\.com\S*[^\w\-\s])([\w\-]{11})(?=[^\w\-]|$)[?=&+%\w-]* |
                          ^(?:https?:\/\/)?(?:[0-9A-Z-]+\.)?(?:vimeo.com\/)(?:video\/)?(\w+)$'
                          
    belongs_to :videoable, :polymorphic => true
    
    attr_accessible :video_id, :title, :ytid, :description, :duration, :player_url, 
                      :widescreen, :noembed, :state,:is_private,:published_at,:uploaded_at,
                        :updated_at,:video_type,:remote_video_url,:videoable_id,:videoable_type

    #move into videoable
    attr_accessor :video_url
    
    #move into videoable
    before_validation :generate_remote_video, :if => :video_url?
    validates_presence_of :remote_video_url, :if => :video_url?, :message => 'video url is invalid or inaccessible'
                           
    def self.video_exists?(vid)
      find_by_video_id(vid)
    end
    
    def self.ytid_from_video_id video_id
      logger.debug "video id is: #{video_id}"
      logger.debug "unique id is: #{video_id[/videos\/([^<]+)/, 1]}"
      video_id[/videos\/([^<]+)/, 1] || video_id[/video\:([^<]+)/, 1]
    end

    def embeddable?
      not @noembed
    end
    
    def widescreen?
      @widescreen
    end
    
    def is_private?
      @is_private
    end
    
    def embed_html(width = 425, height = 350)
      <<EDOC
<object width="#{width}" height="#{height}">
<param name="movie" value="#{@player_url}"></param>
<param name="wmode" value="transparent"></param>
<embed src="#{embed_url}" type="application/x-shockwave-flash"
 wmode="transparent" width="#{width}" height="#{height}"></embed>
</object>
EDOC
    end
    
    private
      def video_url?
        !self.video_url.blank?
      end

      def generate_remote_video
        #determine if youtube or vimeo
        if get_video_type video_url
          self.video_id = get_video_id url
          #generate remote feed for single video
          vf = Youtuber::Feeds::Vimeo::VideoFeed.new :vid => self.video_id
          video = vf.parse_feed #parse feed should generate error parsing video error
          self = video if video
          self.remote_video_url if self.video_id
        end
        rescue #rescue a failed grabbing of remote feed
      end

      def do_download_remote_image
        io = open(URI.parse(image_url))
        def io.original_filename; base_uri.path.split('/').last; end
        io.original_filename.blank? ? nil : io
      rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
      end
      
      def get_video_type url
        return 'youtube' if url =~ /YOUTUBE_REGEXP/
        return 'vimeo' if url =~ /VIMEO_REGEXP/
        false
      end
      
      def get_video_id url
        return (url =~ /VID_REGEXP/) ? $1 : false
  end
end