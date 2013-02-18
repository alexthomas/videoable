module Videoable
  module Models
    
    def self.config(mod, *accessors) #:nodoc:
      class << mod; attr_accessor :available_configs; end
      mod.available_configs = accessors
      
      accessors.each do |accessor|
        mod.class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{accessor}
            if defined?(@#{accessor})
              Rails.logger.debug "#{accessor} is defined in class"
              @#{accessor}
            elsif superclass.respond_to?(:#{accessor})
              Rails.logger.debug "#{accessor} is defined in superclass"
              superclass.#{accessor}
            else
              Rails.logger.debug "#{accessor} is defaulting to Videoable var"
              Videoable.#{accessor}
            end
          end

          def #{accessor}=(value)
            @#{accessor} = value
          end
        METHOD
      end
    end
    
    
    
    def videoable(*modules)
  
    end

    # The hook which is called inside videoable.
    # So your ORM can include videoable compatibility stuff.
    def videoable_modules_hook!
      yield
    end
    
    module InstanceMethods
      
      def set_instance_variables( variables )
        #Rails.logger.debug " setting instance variables #{variables}"
        variables.each do |key, value|
          name = key.to_s
          #Rails.logger.debug " setting instance variable #{name} to #{value}"
          #Rails.logger.debug " #{name} responded" if respond_to?(name)
          instance_variable_set("@#{name}", value) if respond_to?(name)
        end
      end
    end
    
    
  end
end

  