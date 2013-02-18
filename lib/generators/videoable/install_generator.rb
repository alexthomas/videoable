require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module Videoable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      #include Rails::Generators::ActiveRecord
      
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a Videoable initializer and video table migration."

      def copy_initializer
        template "videoable.rb", "config/initializers/videoable.rb"
      end

      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

      def create_migration_file
        migration_template 'migration.rb', 'db/migrate/create_videoable_video_table.rb'
      end
      
      def generate_model
        #invoke "active_record:model", ["Video"], :migration => false unless model_exists? && behavior == :invoke
      end
    end
  end
end