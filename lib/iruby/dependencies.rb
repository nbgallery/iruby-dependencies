require 'bundler'

# require 'mypki' if requested so it is an active gem
if Bundler.settings['dependencies.mypki']
  require 'mypki' 
  require 'erector'
end

if gems = Bundler.settings['dependencies.require']
  gems.split(':').each {|gem| require gem}
end

require 'iruby/dependencies/dsl'
require 'iruby/dependencies/config'
require 'iruby/dependencies/shared_helpers'
require 'iruby/dependencies/version'

module IRuby
  module Dependencies
    ACTIVE_GEMS = {}

    # this code is taken from bundler/inline with small changes
    def self.dependencies verbose: false, &gemfile
      if ACTIVE_GEMS.empty?
        ACTIVE_GEMS.merge! Gem.loaded_specs.map{|n,s| [n,s.version.to_s]}.to_h
      end

      Bundler.ui = verbose ? Bundler::UI::Shell.new : nil
      MyPKI.init if Bundler.settings['dependencies.mypki']
      
      warn 'Dependencies installing. This could take a minute ...'
      old_root = Bundler.method(:root)
      
      def Bundler.root
        Bundler::SharedHelpers.pwd.expand_path
      end
      
      ENV['BUNDLE_GEMFILE'] ||= 'Gemfile'

      builder = Dsl.new
      builder.instance_eval(&gemfile)

      Gem::ConfigFile.new ['sources']
      Gem.sources.each {|s| builder.source s}

      ACTIVE_GEMS.each do |name,version|
        builder.gem name, version, require: false
      end

      Config.process builder
      definition = builder.to_definition(nil, true)

      def definition.lock(*); end
      definition.validate_ruby!

      Bundler::Installer.install(Bundler.root, definition, :system => true)

      runtime = Bundler::Runtime.new(nil, definition)
      runtime.setup.require

      bundler_module = class << Bundler; self; end
      bundler_module.send(:define_method, :root, old_root)

      html = IRuby.html <<-HTML
        <div style='
          margin: -0.4em; 
          padding: 0.4em; 
          background: rgba(0, 255, 0, .3); 
          font-family: monospace;
        '>
          Dependencies successfully installed.
        </div>
      HTML

      IRuby.display html; nil
    end
  end
end

def dependencies *args, &block
  IRuby::Dependencies.dependencies *args, &block
end
