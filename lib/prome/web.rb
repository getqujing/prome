require 'prometheus/client/rack/exporter'

module Prome
  class Web
    class << self
      def call(env)
        exporter = Prometheus::Client::Rack::Exporter.new(nil, registry: Prome.registry, path: "/")
        exporter.call(env)
      end
    end
  end
end