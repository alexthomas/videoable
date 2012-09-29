module Youtuber
  module Models
    module Videoable
      
      def self.included(base)
          base.has_one :video, :as => :videoable, :class_name => "Youtuber::Video"
          base.accepts_nested_attributes_for :video_attributes
      end
      
      module ClassMethods
        Youtuber::Models.config(self)
        
        
        
      end
      
    end
  end
end