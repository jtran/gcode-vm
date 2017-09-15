# Note: This should be the first thing required so that the correct gem versions
# are loaded.
if RUBY_VERSION < '2.2.2'
  $stderr.puts "Ruby v2.2.2 or greater is required; you're using v#{RUBY_VERSION}"
  exit 1
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
