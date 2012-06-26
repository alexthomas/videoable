class Initializer2Generator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  
  def copy_initializer_file
      copy_file "initializer2.rb", "config/initializers/#{file_name}.rb"
    end
end
