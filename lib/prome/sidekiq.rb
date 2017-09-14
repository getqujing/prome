require 'rack'
require 'prometheus/client/rack/exporter'

module Prome
  module Sidekiq
    module Middleware
      module Instrumentation
        def self.labelize(worker, job, queue)
          labels = {queue: queue}
          if worker.is_a?(ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper)\
              || worker === "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper"
            labels[:worker] = job["wrapped"]
          else
            labels[:worker] = worker.class.to_s
          end
          labels
        end
        
        class Server
          def call(worker, job, queue)
            labels = Instrumentation.labelize(worker, job, queue)
            start = Time.now
            begin
              yield
              Prome.get(:sidekiq_jobs_success_total).increment(labels)
            rescue Exception
              Prome.get(:sidekiq_jobs_failed_total).increment(labels)
              raise
            ensure
              Prome.get(:sidekiq_jobs_executed_total).increment(labels)
              Prome.get(:sidekiq_job_runtime_seconds).observe(labels, elapsed(start))
            end
          end

          private
          def elapsed(start)
            (Time.now - start).round(3)
          end
        end

        class Client
          def call(worker, job, queue, redis_pool)
            labels = Instrumentation.labelize(worker, job, queue)
            Prome.get(:sidekiq_jobs_enqueued_total).increment(labels)
            yield
          end
        end
      end
    end

    class << self
      def install!
        if defined?(::Sidekiq)
          if ::Sidekiq.server?
            ::Sidekiq.configure_server do |config|
              config.server_middleware do |chain|
                chain.add Prome::Sidekiq::Middleware::Instrumentation::Server
              end
            end
            start_metrics_server
          else
            ::Sidekiq.configure_client do |config|
              config.client_middleware do |chain|
                chain.add Prome::Sidekiq::Middleware::Instrumentation::Client
              end
            end
          end
        end
      end
      
      def start_metrics_server
        app = Rack::Builder.new do
          use Rack::CommonLogger, ::Sidekiq.logger
          use Rack::ShowExceptions
          use Prometheus::Client::Rack::Exporter, registry: Prome.registry
          run ->(env) { [404, {'Content-Type' => 'text/plain'}, ["Not Found\n"]]}
        end

        Thread.new do
          Rack::Handler::WEBrick.run(app,
            Host: Prome.sidekiq_metrics_host,
            Port: Prome.sidekiq_metrics_port,
            AccessLog: [])
        end
      end
    end
  end
end
