class StatusesController < ApplicationController
  def show
    render json: {
      status: "OK",
      rails_version: Rails::VERSION::STRING,
      ruby_version: RUBY_VERSION,
      rails_env: Rails.env,
      config: ActiveRecord::Base.connection_config.slice(:database, :host, :port)
      # tcp_open: Socket.tcp("www.ruby-lang.org", 10567, connect_timeout: 5) {}
    }
  end
end
