<<<<<<< HEAD:tasks/translate_routes_tasks.rake
config_path = File.expand_path(File.join(RAILS_ROOT, 'config'))
=======
# config_path = File.expand_path(File.join(RAILS_ROOT, 'config'))
# require File.join(config_path, 'environment')
>>>>>>> 168019e4a438a41c6f3fcf2e1a9c8e4539ecd3b3:lib/tasks/translate_routes_tasks.rake

# namespace :translate_routes do              

# http://github.com/thecocktail/translate_routes/commit/222190a039ad26f4d3ab5e5c8a8a410f9687be68
namespace :translate_routes => :environment do

  desc "Updates yaml translation files for the given languages"
  task :update_yaml, :langs, :needs => :environment do |task, args|
    segments = ActionController::Routing::Translator.original_static_segments
    
    if args[:langs].is_a?(String)    
      langs = args[:langs] + ' ' + ActionController::Routing::Translator.default_locale            
      langs.split.uniq.each do |lang|

        file_path = File.join(config_path, "routes_#{lang}.yml");

        if File.exists?(file_path)
          puts "Updating #{file_path}"
          translations = YAML.load_file(file_path)          
          f = File.open(file_path,'w')
        else
          puts "Creating #{file_path}"
          translations = {}
          f = File.new(file_path, 'w')
        end

        f.write "#{lang}:\n"
        segments.each do |s|
          translation = translations[lang][s] rescue ''
          f.write "  #{s}: #{translation}\n"
        end
        f.close
      end

    else
      puts 'Missing parameters, usage example: rake translate_routes:update_yaml["fr de es"]'
    end
  end
end
