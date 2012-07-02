
module Youtuber

  class Engine < Rails::Engine

    initializer "youtuber.load_app_instance_data" do |app|
      Youtuber.setup do |config|
        config.app_root = app.root
      end
    end

    initializer "team_page.load_static_assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
    
    
  end

end