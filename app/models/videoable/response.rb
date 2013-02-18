module Videoable
  
  class Response
     include Videoable::Models.const_get("InstanceMethods")
     attr_reader :feed_id,:items_per_page,:page,:entries
   
     def initialize(params)
       set_instance_variables(params)
     end
  end
  
end