require 'graphql'
require 'graphql/client'
require 'pry'

RSpec.configure do |config|
  config.order = :random
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

