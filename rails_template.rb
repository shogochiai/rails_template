# coding: utf-8
# These are based on https://github.com/patorash/rails_template
dir = File.dirname(__FILE__)

gem 'slim-rails'
gem 'simple_form', github: 'plataformatec/simple_form', branch: 'master'
gem 'ransack'
gem 'kaminari'
gem 'selenium-webdriver'
gem 'nokogiri'
gem 'active_decorator'
gem 'active_attr'

use_bootstrap = if yes?('Use Bootstrap?')
                  uncomment_lines 'Gemfile', "gem 'therubyracer'"
                  gem 'less-rails'
                  gem 'twitter-bootstrap-rails'
                  true
                else
                  false
                end

gem 'whenever', require: false if yes?('Use whenever?')

gem_group :development, :test do
  gem 'rspec-rails'
  gem "factory_girl_rails"
  gem 'capybara'
  gem 'capybara-webkit'
end

gem_group :development do
  gem 'pry-rails'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'spring'
  gem 'letter_opener'
  gem 'annotate'
  gem 'thin'
end

gem_group :test do
  gem 'database_cleaner'
  gem 'timecop'
  gem 'launchy'
  gem 'webmock', require: 'webmock/rspec'
end

run_bundle
generate 'kaminari:config'
generate 'rspec:install'
remove_dir 'test'

if use_bootstrap
  generate 'bootstrap:install', 'less'
  generate 'simple_form:install', '--bootstrap'
  if yes?("Use responsive layout?")
    generate 'bootstrap:layout', 'application fluid'
  else
    generate 'bootstrap:layout', 'application fixed'
    append_to_file 'app/assets/stylesheets/application.css' do
      "body { padding-top:60px }"
    end
  end
  remove_file 'app/views/layouts/application.html.erb'
else
  generate 'simple_form:install'
end

# Application settings
# ----------------------------------------------------------------
application do
  %q{
    config.active_record.default_timezone = :local
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja

    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec, fixture: true, fixture_replacement: :factory_girl
      g.view_specs false
      g.controller_specs false
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
      g.assets false
      g.helper false
    end

    config.autoload_paths += %W(#{config.root}/lib)
  }
end

# Environment setting
# ----------------------------------------------------------------
comment_lines 'config/environments/production.rb', "config.serve_static_assets = false"
environment 'config.serve_static_assets = true', env: 'production'
environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'


# .gitignore settings
# ----------------------------------------------------------------
remove_file '.gitignore'
create_file '.gitignore' do
  body = <<EOS
/.bundle
/vendor/bundle
/db/*.sqlite3
/log/*.log
/tmp
.DS_Store
/public/assets*
/config/database.yml
newrelic.yml
.foreman
.env
doc/
*.swp
*~
.project
.idea
.secret
/*.iml
EOS
end

# Root path settings
# ----------------------------------------------------------------
generate 'controller', 'home index'
route "root to: 'home#index'"



# Create directories
# ----------------------------------------------------------------
empty_directory 'app/decorators'
create_file 'app/decorators/.gitkeep'

# Database settings
# ----------------------------------------------------------------
case gem_for_database
  when 'mysql2'
    run "sed -i -e \"s/#{app_name}_test/#{app_name}_test<%= ENV[\\'TEST_ENV_NUMBER\\']%>/g\" config/database.yml"
  when 'sqlite3'
    run "sed -i -e \"s/db\\/test.sqlite3/db\\/test<%= ENV[\\'TEST_ENV_NUMBER\\']%>.sqlite3/g\" config/database.yml"
  else
end

run "cp config/database.yml config/database.yml.sample"


rake 'db:migrate:reset'

# git
# ----------------------------------------------------------------
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

exit
