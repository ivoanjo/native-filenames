# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake", "~> 13.0"
gem "rake-compiler", "~> 1.2"
gem "pry"
gem "pry-byebug"
gem "rspec"
gem "standard", "~> 1.41" if RUBY_VERSION >= "3.0"
gem "direct-bind"
gem "bigdecimal", ">= 3" # For testing
