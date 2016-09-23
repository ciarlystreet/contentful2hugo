lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'c2h/version'

Gem::Specification.new do |s|
  s.name        = 'c2h'
  s.version     = C2H::VERSION
  s.date        = '2015-12-07'
  s.summary     = 'Contentful 2 Hugo'
  s.description = 'A tool to create content-files for hugo from content on contentful'
  s.authors     = ['Tortus Tek, Inc.']
  s.email       = 'support@tortus.com'
  s.homepage    = 'https://github.com/tortus/contentful2hugo'
  s.license     = 'Apache License 2.0'

  s.files       = `git ls-files`.split($/)
  s.bindir      = 'bin'
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency "contentful", ["= 0.8.0"]
  s.add_runtime_dependency "choice", ["= 0.2.0"]

  s.add_development_dependency "bundler", "~> 1.12.0"
  s.add_development_dependency "rake", ">= 10.0"
  s.add_development_dependency "minitest", "~> 5.9.0"
end
