module Youtuber
  class Video < ActiveRecord::Base
    include Youtuber::Models.const_get("InstanceMethods")
    set_table_name "yt_videos"
    belongs_to :videoable, :polymorphic => true
    
    attr_accessible :video_id, :title, :ytid, :description, :duration, :player_url, 
                  :widescreen, :noembed, :state,:is_private,:published_at,:uploaded_at,:updated_at

                  
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
    
  end
end