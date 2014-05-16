# coding: utf-8


gem 'sorcery'
gem 'simple_form', '~> 3.0.1'
gem 'ransack', '~> 1.1.0'
gem 'kaminari', '~> 0.15.1'
gem 'selenium-webdriver'
gem 'nokogiri'
gem 'compass-rails', '~> 1.1.3'
# gem 'active_decorator', '~> 0.3.4'
# gem 'active_attr'
# gem 'delayed_job_active_record', '~> 4.0.0'
# このへん消しとくとrails4.1でpolyamorousバグに遭遇しない
gem 'mini_magick'
gem 'carrierwave'
# gem 'whenever', require: false if yes?('Use whenever?')

# gem 'slim'
# gem 'slim-rails'
gem 'bootstrap-sass'
use_bootstrap = true

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'shoulda-matchers'
  gem 'guard-rspec', require: false
  gem 'factory_girl_rails'
  # gem 'parallel_tests'
end

gem_group :development do
  gem 'pry-rails'
  gem 'better_errors'
  gem 'letter_opener'
  gem 'annotate'
  gem 'thin'
  gem 'bullet'
  gem 'quiet_assets'
  gem 'binding_of_caller'
  # gem 'html2slim'
end

comment_lines 'Gemfile', /gem 'turbolinks'/
uncomment_lines 'Gemfile', /gem 'therubyracer'/
gsub_file 'app/views/layouts/application.html.erb', /, "data-turbolinks-track" => true /, ''

run 'bundle install --path vendor/bundle'

generate 'kaminari:config'
generate 'rspec:install'
remove_dir 'test'

# run %Q(erb2slim app/views/layouts/application.html.erb app/views/layouts/application.html.slim && rm app/views/layouts/application.html.erb)

if use_bootstrap
  generate 'simple_form:install', '--bootstrap'

  remove_file 'app/assets/stylesheets/application.css'
  create_file 'app/assets/stylesheets/application.css' do
    body = <<EOS
/*
 *= require_self
 *= require bootstrap
 *= require_tree .
 */
EOS
  end
  gsub_file 'app/assets/javascripts/application.js', /= require turbolinks/, "= require bootstrap"

  create_file 'app/assets/stylesheets/base.css.scss' do
     body = <<EOS
@import "bootstrap";
EOS
  end
else
  generate 'simple_form:install'
end



#gem 'rails_12factor', group: :production

run "bundle install --path vendor/bundle"
#use_heroku = true

#if use_heroku
#  run 'heroku create --remote staging'
#  git push: 'staging master  &> /dev/null'
#end

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
/db/schema.rb
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
*.rbc
capybara-*.html
.rspec
/public/system
/coverage/
/spec/tmp
**.orig
rerun.txt
pickle-email-*.html
config/initializers/secret_token.rb
config/secrets.yml
.rvmrc
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

# DB
# ----------------------------------------------------------------
run 'be rake db:create'
run 'be rake db:migrate'

# Parallel test
# ----------------------------------------------------------------
# rake 'parallel:create'
# rake 'parallel:prepare'

# GuardとFactoryGirlの設定もしたい
# spec_helper.rb
# config.include FactoryGirl::Syntax::Methods

# git
# ----------------------------------------------------------------
git :init
git add: ".  &> /dev/null"
git commit: %Q{ -m 'Initial commit' &> /dev/null }

exit
