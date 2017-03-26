require 'prometheus/client/rack/exporter'

module Prome
  class Web
    class << self
      def call(env)
        refresh
        exporter = Prometheus::Client::Rack::Exporter.new(nil, registry: Prome.registry, path: "/")
        exporter.call(env)
      end

      def refresh
        if defined?(::Sidekiq)
          stats = ::Sidekiq::Stats.new
          stats.queues.each do |k, v|
            Prome.get(:sidekiq_jobs_waiting_count).set({queue: k}, v)
          end
        end
      end
    end
  end
end