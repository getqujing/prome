require 'prometheus/client/registry'

module Prome
  class Registry < Prometheus::Client::Registry
    # override register for convenience
    def register(metric)
      get(metric.name.to_sym) || super(metric)
    end
  end
end