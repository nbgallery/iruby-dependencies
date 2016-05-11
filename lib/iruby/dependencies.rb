require 'bundler'
require 'iruby/dependencies/dsl'
require 'iruby/dependencies/config'
require 'iruby/dependencies/version'

# require 'mypki' if requested so it is an active gem
require 'mypki' if Bundler.settings['dependencies.mypki']

module IRuby
  module Dependencies
    paths = Gem.path.map {|p| File.join p, 'gems'}

    # activate default gems
    %w[bigdecimal io-console json psych rdoc].each {|g| gem g}

    ACTIVE_GEMS = $LOAD_PATH.each_with_object({}) do |path,hash|
      paths.each do |gem_path|
        match = path.match /#{gem_path}\/((?:\w|-)+)-((?:\d+\.?)+)/
        hash.merge! Hash[*match.captures] unless match.nil?
      end
    end

    # this code is taken from bundler/inline with small changes
    def self.dependencies verbose: false, &gemfile
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
