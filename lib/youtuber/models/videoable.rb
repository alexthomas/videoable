module Youtuber
  module Models
    module Videoable
      extend ActiveSupport::Concern
      included do
                              
        has_many :videos, :as => :videoable, :class_name => "Youtuber::Video"
        accepts_nested_attributes_for :videos, :reject_if => :all_blank, :allow_destroy => true
        attr_accessible :videos_attributes
        
      end
      
      module ClassMethods
        Youtuber::Models.config(self)
      end
      
    end
  end
end