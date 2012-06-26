module Youtuber
  class Video
    
    belongs_to :videoable, :polymorphic => true
    
    def self.video_exists?(vid,host)
      find_by_video_id_and_host(vid,host)
    end
    
  end
end