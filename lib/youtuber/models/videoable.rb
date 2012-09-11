module Youtuber
  module Models
    module Videoable
      
      module ClassMethods
        Youtuber::Models.config(self)
        class_eval do
          has_one :video, :as => :videoable, :class_name => "Youtuber::Video"
          accepts_nested_attributes_for :video_attributes
        end
        
      end
      
    end
  end
end