require 'open3'

module IRuby
  module Dependencies
    class Dsl < ::Bundler::Dsl
      def config hash
        hash.each do |key,value|
          Bundler.settings[key] = value
        end
      end

      def exec string
        stdout, stderr, exit_status = Open3.capture3(string)

        if exit_status.success?
          Bundler.ui.info stdout unless stdout.empty?
          Bundler.ui.warn stderr unless stderr.empty?
        else
          puts stdout unless stdout.empty?
          warn stderr unless stderr.empty?
          raise "\"exec '#{string}'\" failed on dependency installation"
        end
      end

      def eval string
        super string
      end

      def css *paths
        paths.each do |path|
          url = full_url path
          html = "<link rel='stylesheet' href='#{url}'>"
          IRuby.display IRuby.html(html)
        end
      end

      def define hash
        mapped = hash.map do |mod,path|
          [mod, full_url(path)]
        end.to_h

        js = <<-JS
          requirejs.config({
            map: {
              '*': #{MultiJson.dump(mapped)}
            }
          });
        JS

        IRuby.display IRuby.javascript(js)
      end

      def script *paths
        paths.each do |path|
          url = full_url path
          html = "<script src='#{url}'></script>"
          IRuby.display IRuby.html(html)
        end
      end

      def url url
        @url = url
      end

      def gem name, *args
        if version = ACTIVE_GEMS[name]
          options = args.last.is_a?(Hash) ? args.pop.dup : {}

          unless args.empty? or args == [version]
            raise GemfileError, "The IRuby runtime has already loaded #{name}-#{version}. If you need a different version, you'll need to install it manually and restart IRuby."
          else
            super name, [version], options
          end
        else
          super name, *args
        end
      end

      private 

      def full_url path
        if path[/^https?:/]
          path
        else
          if @url
            File.join @url, path
          elsif url = Bundler.settings['dependencies.url']
            File.join url, path
          else
            raise "Cannot inject #{path} without a base url"
          end
        end
      end
    end
  end
end