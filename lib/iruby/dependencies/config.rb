require 'net/https'
require 'multi_json'

module IRuby
  module Dependencies
    class Config
      def self.process builder
        if url = Bundler.settings['dependencies.config']
          begin 
            uri = URI Bundler.settings['dependencies.config']
            config = MultiJson.load(Net::HTTP.get(uri))
          rescue => ex
            warn "Could not fetch remote IRuby::Dependencies config from #{url}: #{ex.message}"
          else
            loop do 
              gem_added = false

              if commands = config.delete('*')
                commands.each do |command|
                  method, *args = command
                  builder.send method, *args
                  gem_added ||= method == 'gem'
                end
              end

              definition = builder.to_definition nil, true
              #definition.resolve
              
              definition.specs.each do |spec|
                if commands = config.delete(spec.name)
                  commands.each do |command|
                    method, *args = command
                    builder.send method, *args
                    gem_added ||= method == 'gem'
                  end
                end
              end

              break unless gem_added
            end
          end
        end
      end
    end
  end
end
