# -*- encoding: utf-8 -*-
require File.expand_path('../lib/easy_mongoid_tag/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'easy_mongoid_tag'
  s.version     = EasyMongoidTag::VERSION
  s.date        = '2013-09-05'
  s.summary     = "粗糙的mongid tag"
  s.description = "粗糙的mongid tag"
  s.authors     = ["Wade Xing"]
  s.email       = ['iamxingxing@gmail.com']
  s.files       = `git ls-files`.split($\)
  
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.require_paths = ['lib']

  s.homepage    = 'https://github.com/xingxing/easy_mongoid_tag'

  s.add_runtime_dependency 'mongoid', '~> 3.1.0'

  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'mongoid-rspec', '~> 1.9.0'
  s.add_development_dependency 'guard', '~> 1.8.0'
  s.add_development_dependency 'guard-rspec', '~> 3.0.0'
  s.add_development_dependency 'guard-spork', '~> 1.5.1'
  s.add_development_dependency 'terminal-notifier-guard', '~> 1.5.3'
end
