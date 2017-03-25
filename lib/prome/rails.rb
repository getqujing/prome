module Prome
  module Rails
    def self.install!
      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, ending, _, payload|
        labels = {
          controller: payload[:params]["controller"],
          action: payload[:params]["action"],
          status: payload[:status],
          format: payload[:format],
          method: payload[:method].downcase
        }
        duration = ending - start

        Prome.get(:rails_requests_total).increment(labels)
        Prome.get(:rails_request_duration_seconds).observe(labels, duration.to_f / 1000)
        Prome.get(:rails_view_runtime_seconds).observe(labels, payload[:view_runtime].to_f / 1000)
        Prome.get(:rails_db_runtime_seconds).observe(labels, payload[:db_runtime].to_f / 1000)
      end
    end
  end
end