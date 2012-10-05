module Youtuber
  module Models
    module Videoable
      extend ActiveSupport::Concern
      included do
        has_one :video, :as => :videoable, :class_name => "Youtuber::Video"
        accepts_nested_attributes_for :video
        attr_accessor :video_attributes
      end
      
      module ClassMethods
        Youtuber::Models.config(self)
        
        
      end
      
    end
  end
end