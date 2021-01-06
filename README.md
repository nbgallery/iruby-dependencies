# IRuby::Dependencies

`IRuby::Dependencies` is a thin wrapper around [bundler/inline](https://bundler.io/guides/bundler_in_a_single_file_ruby_script.html) for injecting Ruby dependencies into Jupyter Notebooks along with their system dependencies. For example, 

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

## Configuration

Most Jupyter notebooks run in highly reproducible environments (e.g. Docker containers). An `IRuby::Dependencies` can be created that maps gems to the commands that must be executed before that gem can be installed. The config location should be saved as a [Bundler config](https://bundler.io/v2.1/bundle_config.html) with the key `dependencies.config`. The config location can be a local file path or URL. For example:

```bash
$ bundle config dependencies.config /home/jovyan/dependencies.config
```

RemThe config file itself is a JSON file that maps gem names to commands that should be executed before the gem is installed. For instance, in a CentOS/RHEL environment, the config entry would install the `gsl` YUM package before installing the `gsl` RubyGem:

```json
{ 
    'gsl': [
        ["exec", "yum install gsl"]
    ]
}
```

## Usage

To see the normal bundler output, pass `verbose: true` to the dependencies method: 

```
dependencies verbose: true do 
  gem 'http'
  gem 'addressable'
end
```