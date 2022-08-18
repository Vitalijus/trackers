require 'rails_helper'

RSpec.describe "Statuses", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/statuses/show"
      expect(response).to have_http_status(:success)
    end
  end

end
