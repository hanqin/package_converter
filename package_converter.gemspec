# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "package_converter"
  gem.version       = 0.1
  gem.summary = %q{helps you change the android package name}
  gem.authors       = ["Han Qin"]
  gem.email         = %w(hanhaify@gmail.com)
  gem.description   = %q{a tool to help you change the android package name}
  gem.homepage      = "https://github.com/hanqin/package_converter"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w(lib)

  gem.add_development_dependency "rake",  "~> 10.0.2"
end