# Prome
Prometheus for rails and optional sidekiq.

### get started

In your Gemfile, add this

```ruby
gem 'prome', github: 'getqujing/prome'
```

In config/routes.rb, mount the metrics endpoint

```ruby
require 'prome/web'
mount Prome::Web, at: "/metrics"
```

And you are good to go.

### sidekiq

Sidekiq server side metrics are served by a standalone web server, by default it will listen to `0.0.0.0:9310` when you start the sidekiq server.

The bind address can be configured like this, in `config/initializers/prometheus.rb`

```
Prome.configure do |config|
  config.sidekiq_metrics_host = "127.0.0.1"
  config.sidekiq_metrics_port = 3001
end
```

### default metrics

|name|type|description|
|---|---|---|
|`rails_requests_total`|counter|number of HTTP requests rails processed|
|`rails_request_duration_seconds`| histogram |A histogram of the response latency|
|`rails_view_runtime_seconds`|histogram|view rendering time per request|
|`rails_db_runtime_seconds`|histogram|activerecord execution time per request|
|`sidekiq_jobs_executed_total`|counter|number of jobs sidekiq executed|
|`sidekiq_jobs_success_total`|counter|number of jobs successfully processed by sidekiq|
|`sidekiq_jobs_failed_total`|counter|number of jobs failed in sidekiq|
|`sidekiq_job_runtime_seconds`|histogram|job execution time|
|`sidekiq_jobs_enqueued_total`|counter|number of jobs sidekiq enqueued.|
|`sidekiq_jobs_waiting_count`|gauge|number of jobs waiting to process in sidekiq.|

**Note: all sidekiq related metrics are started from the moment using this gem, not equal to `Sidekiq::Stats`**

### custom metrics

Register the metric in initializer

```
Prome.configure do |config|
  Prome.counter(:app_posts_created_total, "A counter of total number of posts created.")
  # Prome also responds to :histogram, :gauge, :summary, just register what you want :)
end
```

In `Post` model

```
class Post < ApplicationRecord
  after_create do
    Prome.get(:app_posts_created_total).increment({})
  end
end
```