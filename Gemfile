#Copyright (c) 2014, IDEO

source "https://rubygems.org"

gem 'async_sinatra'
gem 'eventmachine', '1.0.3'
gem 'sinatra', '1.3.3'
gem 'thin'
gem 'multi_json', '1.7.2'
gem 'em-websocket', '0.5.0'
gem 'logging'

group :mongo do
  gem 'mongo'
  gem 'bson_ext'
end

group :riak do
  gem 'riak-client', '1.1.1'
end

group :test do
  gem 'jasmine'
  gem 'rspec'
  gem 'surrogate'
  gem 'rack-test'
  gem 'rake'
  gem 'rack'
end

group :release do
  gem 'releasy'
end
