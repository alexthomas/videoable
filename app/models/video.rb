module Youtuber
  class Video
    
    belongs_to :videoable, :polymorphic => true
    
    attr_reader :video_id, :title, :ytid, :description, :duration, :player_url, :widescreen, :noembed, :state,:is_private
    
    def self.video_exists?(vid,host)
      find_by_video_id_and_host(vid,host)
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