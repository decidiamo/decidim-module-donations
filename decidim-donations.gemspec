# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/donations/version"

Gem::Specification.new do |s|
  s.version = Decidim::Donations::VERSION
  s.authors = ["Ivan Vergés"]
  s.email = ["ivan@platoniq.net"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidiamo/decidim-module-donations"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-donations"
  s.summary = "Allows donations in decidim adding a new verification handler."
  s.description = "Donate in order to be verified in Decidim."

  s.files = Dir[
    "{app,config,db,lib}/**/*",
    "LICENSE-AGPLv3.txt",
    "Rakefile",
    "README.md"
  ]

  s.require_paths = ["lib"]

  s.add_dependency "decidim-admin", Decidim::Donations::DECIDIM_VERSION
  s.add_dependency "decidim-core", Decidim::Donations::DECIDIM_VERSION
  s.add_dependency "decidim-verifications", Decidim::Donations::DECIDIM_VERSION

  s.add_development_dependency "decidim-dev", Decidim::Donations::DECIDIM_VERSION
end
