ENV["RAILS_ENV"] ||= 'test'

require 'travis'
require 'travis/hub'
require 'travis/support'
require 'support/active_record'
require 'support/payloads'
require 'stringio'
require 'mocha'

Travis.logger = Logger.new(StringIO.new)

include Mocha::API

RSpec.configure do |c|
  c.mock_with :mocha

  c.before(:each) do
     Time.now.utc.tap { |now| Time.stubs(:now).returns(now) }
   end

  c.after :each do
    Travis.config.notifications.clear
    Travis::Event.instance_variable_set(:@subscriptions, nil)
  end
end
