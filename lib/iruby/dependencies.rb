require 'json'
require 'net/https'
require 'bundler/inline'

module IRuby
  class Dependencies
    def initialize config, verbose: false, &block
      @config = config
      @verbose = verbose 

      instance_eval &block

      gemfile do 
        # tell bundler to use our gem sources
        Gem.sources.each {|source| source source.to_s}
        instance_eval &block
      end
    end

    def gem name, *args
      send *@config[name] if @config[name]
    end

    def exec string
      stdout, stderr, exit_status = Open3.capture3(string)

      if exit_status.success?
        if @verbose 
          Bundler.ui.info stdout unless stdout.empty?
          Bundler.ui.warn stderr unless stderr.empty?
        end
      else
        puts stdout unless stdout.empty?
        warn stderr unless stderr.empty?
        raise "\"exec '#{string}'\" failed on dependency installation"
      end
    end

    # gemfiles allow specifying alternate sources for gems
    # make sure we check the block for gems in those sources
    def source *args, &block
      instance_eval &block if block_given?
    end

    def to_html
      <<-HTML
        <div style='background: rgba(0,255,0,0.3);
                    font-family: monospace;
                    padding: 5px;'>
          <b>Dependencies successfully installed!</b>
        </div>
      HTML
    end
  end
end

def dependencies **params, &block
  config={}

  begin 
    if config_path = Bundler.settings['dependencies.config']
      uri = URI config_path
  
      json = case uri.scheme
        when /http/
          Net::HTTP.get(uri)
        else 
          File.read(uri.path)
        end
  
      config = JSON.parse(json)
    end
  
  rescue => ex
    warn "iruby-dependencies could not load #{config_path}: #{ex.message}"
  end

  IRuby::Dependencies.new config, **params, &block
end
