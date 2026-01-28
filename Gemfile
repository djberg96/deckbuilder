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
gem 'jbuilder'

# PDF generation
gem 'prawn'
gem 'prawn-table'

gem 'bcrypt'
gem 'pg'
gem 'lograge'
gem 'logstash-event'
gem 'net-smtp'
gem 'ostruct'
gem 'sassc-rails'
gem 'sprockets-rails'
gem 'turbolinks'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'listen'
  gem 'rspec-rails', '~> 7.0'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rails-controller-testing'
end

group :test do
  gem 'shoulda-matchers', '~> 5.0'
  gem 'database_cleaner-active_record'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

group :development do
  gem 'web-console', '>= 3.3.0'
end
