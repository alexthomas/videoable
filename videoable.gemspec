$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "videoable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "videoable"
  s.version     = Videoable::VERSION
  s.authors     = ["Alex Thomas"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_runtime_dependency "resque", "~> 1.0"
  s.add_development_dependency "sqlite3"
  s.add_runtime_dependency "jquery-rails"
  s.add_runtime_dependency "nokogiri", "~> 1.5.2"
  s.add_runtime_dependency "oauth", ">= 0.4.3"
  s.add_runtime_dependency(%q<httparty>, [">= 0.4.5"])
  s.add_runtime_dependency(%q<json>, [">= 1.1.9"])
  s.add_runtime_dependency(%q<oauth>, [">= 0.4.3"])
  s.add_runtime_dependency(%q<httpclient>, [">= 2.1.5.2"])
  s.add_runtime_dependency(%q<multipart-post>, [">= 1.0.1"])
end
