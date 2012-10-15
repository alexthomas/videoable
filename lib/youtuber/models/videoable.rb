module Youtuber
  module Models
    module Videoable
      extend ActiveSupport::Concern
      included do
        
        YOUTUBE_REGEXP  = /^(?:https?:\/\/)?(?:[0-9A-Z-]+\.)?(youtu\.be\/|youtube\.com)/
        VIMEO_REGEXP    = /^(?:https?:\/\/)?(?:[0-9A-Z-]+\.)?(vimeo.com)/
        VID_REGEXP      = /^(?:https?:\/\/)?(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube\.com\S*[^\w\-\s])([\w\-]{11})(?=[^\w\-]|$)[?=&+%\w-]* |
                              ^(?:https?:\/\/)?(?:[0-9A-Z-]+\.)?(?:vimeo.com\/)(?:video\/)?(\w+)$/ix
                              
        has_one :video, :as => :videoable, :class_name => "Youtuber::Video"
        accepts_nested_attributes_for :video
        attr_accessor   :video_url,:attached_video,:remote_video
        attr_accessible :video_url,:attached_video,:video_attributes
        
       
        attr_accessor :video_url
        
        #before_save :upload_video, :if => !:video_url?
        before_validation :generate_remote_video, :if => :video_url?
        validates_presence_of :remote_video, :if => :video_url?, :message => 'video url is invalid or inaccessible'
      end
      
      def video_url?
        !self.video_url.blank?
      end

      def upload_video
        uploader = Youtuber::Uploader.new
        uploader.upload self.attached_video
      end
      
      def generate_remote_video
        #determine if youtube or vimeo
        if get_video_type video_url
          vid = get_video_id(video_url)
          #generate remote feed for single video
          vf = Youtuber::Feeds::Vimeo::VideoFeed.new :vid => vid
          video = Youtuber::Feeds::Vimeo::VideoFeed.parse_feed vf.url,vf.vid #parse feed should generate error parsing video error
          Rails.logger.debug "video is #{video.inspect}"
          self.video = video if video
          self.remote_video = true if !self.video.nil?
        end
        rescue #rescue a failed grabbing of remote feed
      end
      
      def get_video_type url
        return 'youtube' if url =~ YOUTUBE_REGEXP
        return 'vimeo' if url =~ VIMEO_REGEXP
        false
      end
      
      def get_video_id url
        video_id = (url =~ VID_REGEXP && $1) ? $1 : false
        video_id = (!video_id && $2) ? $2 : false
      end
      
      module ClassMethods
        Youtuber::Models.config(self)
        
      end
      
    end
  end
end