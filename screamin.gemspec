
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "screamin/version"

Gem::Specification.new do |spec|
  spec.name          = "screamin"
  spec.version       = Screamin::VERSION
  spec.authors       = ["Russell Edens"]
  spec.email         = ["rx@voomify.com"]

  spec.summary       = %q{Automatic application caching}
  spec.description   = %q{Freeing you to focus on developing your application.}
  spec.homepage      = "https://screamin.io"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.required_ruby_version = '> 2.2.2'
  spec.require_paths = ["lib"]
  # spec.extensions    = ["ext/screamin/extconf.rb"]
  spec.add_dependency "dry-configurable", "~> 0.7.0"
  spec.add_dependency "prefatory", "~> 0.1.2"
  # These are optional runtime dependencies
  spec.add_development_dependency "voom-presenters"
  # Actual development depenedencies
  spec.add_development_dependency "shotgun"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "dalli"
  spec.add_development_dependency "sidekiq"
  spec.add_development_dependency "activejob"
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "simplecov"
end
