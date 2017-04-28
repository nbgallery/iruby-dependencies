# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iruby/dependencies/version'

Gem::Specification.new do |spec|
  spec.name          = "iruby-dependencies"
  spec.version       = IRuby::Dependencies::VERSION
  spec.authors       = ["Kyle King"]
  spec.email         = ["kylejking@gmail.com"]

  spec.summary       = %q{IRuby::Dependencies is a module for injecting Ruby dependencies into Jupyter Notebooks}
  spec.homepage      = "https://github.com/jupyter-gallery/iruby-dependencies"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "iruby"
  spec.add_dependency "multi_json"
  spec.add_dependency "bundler", "~> 1.13.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
