class StatusesController < ApplicationController
  def show
    render json: {
      status: "OK",
      ruby_version: Rails::VERSION::STRING,
      rails_env: Rails.env,
      config: ActiveRecord::Base.connection_config.slice(:database, :host, :port)
    }
  end
end
