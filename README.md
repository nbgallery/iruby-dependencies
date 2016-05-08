# IRuby::Dependencies

IRuby::Dependencies is a module for injecting Ruby dependencies into Jupyter Notebooks. For example, 

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

IRuby::Dependencies uses the [Bundler Gemfile syntax](http://bundler.io/v1.5/gemfile.html) with some additional methods:

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

Gems active at the time IRuby::Dependencies are added to the dependency bundle. This means that you cannot specify a different version of a gem already being used by IRuby. If you really need a different version of that gem, install it on the command line and restart the kernel.  
