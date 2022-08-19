class StatusesController < ApplicationController
  def show
    render json: {
      status: "OK",
      rails_version: Rails::VERSION::STRING,
      ruby_version: RUBY_VERSION,
      rails_env: Rails.env,
      config: ActiveRecord::Base.connection_config.slice(:database, :host, :port)
    }
  end
end
