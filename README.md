# IRuby::Dependencies

`IRuby::Dependencies` is a module for injecting Ruby dependencies into Jupyter Notebooks. For example, 

```ruby 
require 'iruby/dependencies'

dependencies do 
  gem 'http'
  gem 'addressable'
end
```

## Installation

```bash
$ gem install iruby-dependencies
```

You'll have to restart any IRuby kernels already running. 

## Usage

`IRuby::Dependencies` uses the [Bundler Gemfile syntax](http://bundler.io/v1.5/gemfile.html) with some additional methods:

| Method | Description |
| ------ | ----------- |
| `script <url>` | Loads the javascript at the given url into the notebook as a `script` tag |
| `define <hash>` | Defines alternate paths for requirejs modules. Keys are modules, values are paths |
| `exec <string>` | Executes the system command, for example `yum install gsl` |
| `css <string>` | Loads the stylesheet at the given url into the notebook as a `link` tag 

To see the normal bundler output, pass `verbose: true` to the dependencies method: 

```
dependencies verbose: true do 
  gem 'http'
  gem 'addressable'
end
```

## Active Gems

When `IRuby::Dependencies` is first loaded, it saves a list of all active gems, which are added to the dependency bundle. For example, since IRuby uses multi_json, the multi_json gem is always included in the bundle. Active gems cannot be removed and their versions are fixed. If you need a different version of an active gem, install it on the command line and restart the kernel. To reduce the number of active gems, `require 'iruby/dependencies'` as early in your notebook as possible. 
