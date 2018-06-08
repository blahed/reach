# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reach/version'

Gem::Specification.new do |spec|
  spec.name          = 'reach'
  spec.version       = Reach::VERSION
  spec.authors       = ['blahed']
  spec.email         = ['trvsdnn@gmail.com']
  spec.description   = "Deployment"
  spec.summary       = "and other"
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'sshkit', '~> 1.16.1'
  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'airbrussh', '~> 1.3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
