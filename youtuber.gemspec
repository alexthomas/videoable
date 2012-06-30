$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "youtuber/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "youtuber"
  s.version     = Youtuber::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Youtuber."
  s.description = "TODO: Description of Youtuber."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.0"
  s.add_runtime_dependency "nokogiri", "~> 1.5.2"
  s.add_development_dependency "sqlite3"
  s.add_dependency "jquery-rails"
end
