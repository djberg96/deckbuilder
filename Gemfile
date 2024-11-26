source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 7.2'

gem 'auto_strip_attributes'
gem 'puma'
gem 'terser'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'bcrypt'
gem 'pg'
gem 'lograge'
gem 'logstash-event'
gem 'net-smtp'
gem 'sprockets-rails'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'listen'
end

group :development do
  gem 'web-console', '>= 3.3.0'
end
