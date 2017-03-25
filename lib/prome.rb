require 'prome/version'
require 'prometheus/client/registry'
require 'prome/rails'

module Prome
  mattr_accessor :registry do
    r = Prometheus::Client::Registry.new

    # rails
    r.counter(:rails_requests_total, "A counter of the total number of HTTP requests rails processed.")
    r.histogram(:rails_request_duration_seconds, "A histogram of the response latency.")
    r.histogram(:rails_view_runtime_seconds, "A histogram of the view rendering time.")
    r.histogram(:rails_db_runtime_seconds, "A histogram of the activerecord execution time.")

    r
  end

  class << self
    delegate :counter, :gauge, :histogram, :summary, :get, to: :registry

    def configure_registry
      yield self.registry
    end
  end
end

Prome::Rails.install!