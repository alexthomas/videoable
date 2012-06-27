module Youtuber
  module Helpers
    module YoutuberHelper
      def integer_or_default(value,default)
        value.to_i > 0 ? value : default
      end
    end
  end
  
end