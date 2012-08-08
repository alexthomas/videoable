module Youtuber

  module Apis
    
    class VimeoApi < Youtuber::Api
      
      def create_api_method(method, vimeo_method, options={})
        options = { :required => [], :optional => [] }.merge(options)

        method = method.to_s

        raise ArgumentError, 'Required parameters must be an array.' unless options[:required].is_a? Array
        raise ArgumentError, 'Optional parameters must be an array.' unless options[:optional].is_a? Array

        required = options[:required].map { |r| r.to_s }.join(",")
        optional = options[:optional].map { |o| ":#{o} => nil" }.join(",")
        authorized = options.fetch(:authorized, true)

        parameters = "(#{required unless required.empty?}#{',' unless required.empty?}options={#{optional}})"

        method_string = <<-method

          def #{method}#{parameters}
            raise ArgumentError, 'Options must be a hash.' unless options.is_a? Hash

            sig_options = {
              :method => "#{vimeo_method}",
              :format => "json"
            }

            #{ options[:required].map { |r| "sig_options.merge! :#{r} => #{r}"}.join("\n") }
            #{ options[:optional].map { |o| "sig_options.merge! :#{o} => options[:#{o}] unless options[:#{o}].nil?" }.join("\n") }

            make_request sig_options, #{authorized ? "true" : "false"}
          end

        method

        class_eval method_string
      end
    end
    
  end

end