require 'bundler'

# a minor modification of the code from the 
# bundler-unload gem
module Bundler 
  ORIGINAL_SPECS = []

  class << self
    def unload!
      if ORIGINAL_SPECS.empty?
        ORIGINAL_SPECS.concat Gem::Specification._all
      end

      @load = @definition = nil
      ENV.replace ORIGINAL_ENV
      Gem::Specification.all = ORIGINAL_SPECS
    end
  end
end