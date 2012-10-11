require 'travis/hub/handler/job'
require 'travis/hub/handler/request'
require 'travis/hub/handler/sync'
require 'travis/hub/handler/worker'

module Travis
  module Hub
    module Handler

      class << self
        def handle(event, payload)
          self.for(event, payload).handle
        end

        def for(event, payload)
          case event_type(event, payload)
          when /^request/
            Handler::Request.new(event, payload)
          when /^job/
            Handler::Job.new(event, payload)
          when /^worker/
            Handler::Worker.new(event, payload)
          when /^sync/
            Handler::Sync.new(event, payload)
          else
            raise "Unknown message type: #{event.inspect}"
          end
        end

        def event_type(event, payload)
          (event || extract_event(payload)).to_s
        end

        def extract_event(payload)
          warn "Had to extract event from payload: #{payload.inspect}"
          case payload['type']
          when 'pull_request', 'push'
            'request'
          else
            payload['type']
          end
        end
      end
    end
  end
end