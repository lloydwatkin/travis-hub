module Travis
  class Hub
    module Monitoring
      def self.start
        puts "Starting New Relic with env:#{ENV['ENV']}"
        require 'newrelic_rpm'

        Travis::Hub::Handler::Job.class_eval do
          include NewRelic::Agent::Instrumentation::ControllerInstrumentation
          add_transaction_tracer(:handle_log_update)
          add_transaction_tracer(:handle_update)
        end

        Travis::Hub::Handler::Worker.class_eval do
          include NewRelic::Agent::Instrumentation::ControllerInstrumentation
          add_transaction_tracer(:handle)
        end

        require 'travis/notifications'
        ['Pusher', 'Email', 'Irc', 'Campfire', 'Webhook'].each do |service|
          module Travis::Notifications
            service.class_eval do
              include NewRelic::Agent::Instrumentation::ControllerInstrumentation
              add_transaction_tracer(:notify, :category => :task)
            end
          end
        end


        NewRelic::Agent.manual_start(:env => ENV['ENV'])
      rescue Exception => e
        puts 'New Relic Agent refused to start!'
        puts e.message
        puts e.backtrace
      end
    end
  end
end

