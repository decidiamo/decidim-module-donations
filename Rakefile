# frozen_string_literal: true

require "byebug"
require "decidim/dev/common_rake"

def install_module(path)
  Dir.chdir(path) do
    source_path = "#{__dir__}/lib/decidim/donations/generators/app_templates"

    FileUtils.cp(
      "#{source_path}/initializer.rb",
      "config/initializers/decidim_donations.rb"
    )

    system("bundle exec rake decidim_donations:install:migrations")
    system("bundle exec rake db:migrate")
  end
end

def seed_db(path)
  Dir.chdir(path) do
    system("bundle exec rake db:seed")
  end
end

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app" do
  ENV["RAILS_ENV"] = "test"
  install_module("spec/decidim_dummy_app")
end

desc "Generates a development app."
task :development_app do
  Bundler.with_original_env do
    generate_decidim_app(
      "development_app",
      "--app_name",
      "#{base_app_name}_development_app",
      "--path",
      "..",
      "--recreate_db",
      "--demo"
    )
  end

  install_module("development_app")
  seed_db("development_app")
end
