module Videoable
  class Video < ActiveRecord::Base
    include Videoable::Models.const_get("InstanceMethods"), Videoable::VideoUploader
    self.table_name = "yt_videos"
    
    
                          
    belongs_to :videoable, :polymorphic => true
    
    attr_accessible :video_id, :title, :ytid, :description, :thumbnail_url, :duration, :player_url, 
                      :widescreen, :noembed, :state,:is_private,:published_at,:uploaded_at,
                        :updated_at,:video_type,:remote_video_url,:videoable_id,:videoable_type
                           
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
    
    def embed_video(width = 425, height = 350)
      return nil if video_type.nil?
      embed_html = method("#{video_type}_embed_html").call(width,height).strip
      rescue
      embed_html ||= nil
    end
    
    def youtube_embed_html(width = 425, height = 350)
      <<-EMBED
        <iframe width="#{width}" height="#{height}" src="http://www.youtube.com/embed/#{video_id}" frameborder="0" allowfullscreen></iframe>
      EMBED
    end
    
    def vimeo_embed_html(width = 500, height = 375)
      <<-EMBED
        <iframe src="http://player.vimeo.com/video/#{video_id}" width="#{width}" height="#{height}" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe> 
      EMBED
    end
    
    def video_url
      return nil if (video_id.nil? || video_type.nil?)
      watch = (video_type=="youtube") ? "watch?v=#{video_id}": video_id
      "#{video_type}.com/#{watch}"
    end
    
    def embed_url
      return nil if (video_id.nil? || video_type.nil?)
      embed_url = (video_type=="youtube") ? "www.youtube.com/embed/#{video_id}" : "player.vimeo.com/video/#{video_id}"
      "http://" << embed_url
    end
    
    def thumbnail
      thumbnail = self.thumbnail_url.nil? ? "/assets/video-placeholder.jpg" : self.thumbnail_url
      thumbnail
    end
  end
end