module Youtuber
    module VideoUploader
      extend ActiveSupport::Concern
      
      @queue = :upload_queue
      included do
        
        class << self
          @@api = Youtuber::Apis::Vimeo::Video.new
        end
        
        YOUTUBE_REGEXP  = /^(?:https?:\/\/)?(?:[0-9A-Za-z]+\.)?(youtu\.be\/|youtube\.com)/
        VIMEO_REGEXP    = /^(?:https?:\/\/)?(?:[0-9A-Za-z]+\.)?(vimeo.com)/
        VID_REGEXP      = /^(?:https?:\/\/)?(?:[0-9A-Za-z]+\.)?(?:youtu\.be\/|youtube\.com\S*[^\w\-\s])([\w\-]{11})(?=[^\w\-]|$)[?=&+%\w-]*|^(?:https?:\/\/)?(?:[0-9A-Za-z]+\.)?(?:vimeo.com\/)(?:video\/)?(\w+)$/ix

        attr_accessor   :attached_video,:remote_video
        attr_accessible :remote_video_url
        attr_reader :ticket_id

        after_save :upload_video, :if => lambda {|video| !video.remote_video_url? && video.attached_video}
        after_destroy :delete_video
        
        before_validation :generate_video_from_remote, :if => :remote_video_url?
        validates_presence_of :remote_video, :if => :remote_video_url?, :message => 'video url is invalid or inaccessible'
        validates_presence_of :attached_video, :if => lambda {|video| video.remote_video_url.blank? && video.video_id.nil?}, :message => 'you must either upload a video or give a video URL'
      end
      
      
      
      def remote_video_url?
        !self.remote_video_url.blank?
      end

      def upload_video
        Rails.logger.debug "sending upload job to resque #{self.attached_video.inspect}"
        Rails.logger.debug "sending upload job to resque #{self.attached_video.tempfile.path}"
        name = self.attached_video.original_filename
        directory = Rails.root.join("public/assets/videos/#{self.id}/")
        FileUtils.mkdir_p(directory) unless File.exists?(directory)
        path = File.join(directory, name)
        File.open(path, "wb") { |f| f.write(self.attached_video.read) }
        Resque.enqueue(VideoUploader,self.id,path,'upload')
      end
      
      def delete_video
        Resque.enqueue(VideoUploader,self.id,'','delete')
      end
      
      def generate_video_from_remote
        Rails.logger.debug "generating remote video from #{remote_video_url}"
        #determine if youtube or vimeo
        self.video_type = get_video_type remote_video_url
       
        if video_type
          self.video_id = get_video_id remote_video_url
          Rails.logger.debug "video id #{video_id}"
          #generate remote feed for single video
          if !video_id.nil?
            self.remote_video = true
            populate_video_fields_from_remote video_id, video_type
          end
            
        end
      #rescue #rescue a failed grabbing of remote feed
      end
     
      def populate_video_fields_from_remote vid,service
        vf = "Youtuber::Feeds::#{service.camelize}::VideoFeed".constantize.new :vid => vid
        video = "Youtuber::Feeds::#{service.camelize}::VideoFeed".constantize.parse_feed vf.url,vf.vid #parse feed should generate error parsing video error
        Rails.logger.debug "generating remote video in Video Uploader module is #{video.inspect}"
        if !video.nil?
          Rails.logger.debug "setting video instance variables"
          self.video_id = video.video_id
          self.title = video.title unless video.title == 'Untitled'
          self.description = video.description unless video.description.blank?
          self.thumbnail_url = video.thumbnail_url
          self.ytid = video.ytid
          self.duration = video.duration
          self.player_url = video.player_url
          self.widescreen = video.widescreen
          self.noembed = video.noembed
          self.is_private = video.is_private
          self.published_at = video.published_at
          self.uploaded_at = video.uploaded_at
          self.video_type = video.video_type
        end
        video
      end
      
      def get_video_type url
        return 'youtube' if !(url =~ YOUTUBE_REGEXP).nil?
        return 'vimeo' if !(url =~ VIMEO_REGEXP).nil?
        false
      end
      
      def get_video_id url
        video_id = (url =~ VID_REGEXP && $1) ? $1 : $2
      end
      
      def self.perform video_id,uploadable_path,action
        (action=='upload') ? self.upload_video(video_id,uploadable_path) : self.delete_video(video_id)
      end
      
      #add in ability to check if video successfully uploaded or not - if not then delete video
      def self.upload_video video_id,uploadable_path
        Rails.logger.debug "video id is #{video_id}"
        Rails.logger.debug "performing upload resque job for video #{video_id}"
        Rails.logger.debug "uploadble path in perform is #{uploadable_path}"
        video = Video.find video_id
        video.video_type = 'vimeo'
        Rails.logger.debug "pre upload video is #{video.inspect}"
        uploader = Uploader.new
        remote_video_id = uploader.upload uploadable_path, false
        Rails.logger.debug "remote video id #{remote_video_id}"

        video.populate_video_fields_from_remote remote_video_id,video.video_type
        Rails.logger.debug "video after populating fields is #{video.inspect}"
        response = @@api.set_title(remote_video_id, video.title) if !video.title.blank?
        Rails.logger.debug "response from vapi set title #{response.inspect}"
        response = @@api.set_description(remote_video_id, video.description) if !video.description.blank?
        Rails.logger.debug "response from vapi set description #{response.inspect}"
        rescue
        ensure
        video.save if video.changed?
        
      end

      #use try instead of find?
      def self.delete_video video_id
        video = Video.find video_id
        Rails.logger.debug "trying to delete video from vimeo #{video.id}"
        @@api.delete video.video_id
        rescue
      end
      
    end 
end