Gem::Specification.new do |s|
  s.name        = "translate_routes"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Raul Murciano"
  s.email       = "raul@murciano.net"
  s.homepage    = "http://github.com/raul/translate_routes"
  s.summary     = "Translate your routes in a simple manner"
  s.description = "Translates the routes of your application into the langagues defined in your locale files"
 
  s.required_rubygems_version = ">= 1.3.7"

 
  s.files        = Dir.glob("{lib}/**/*") + %w(MIT-LICENSE README.markdown ROADMAP.md ChangeLog)
  s.require_path = 'lib'
end