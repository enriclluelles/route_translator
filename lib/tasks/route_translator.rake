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
