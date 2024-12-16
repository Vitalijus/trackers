class StatusesController < ActionController::Base
  def index
    @results = render html: {
      status: "OK",
      rails_version: Rails::VERSION::STRING,
      ruby_version: RUBY_VERSION,
      rails_env: Rails.env
      # tcp_open: Socket.tcp("www.ruby-lang.org", 10567, connect_timeout: 5) {}
    }
  end
end
