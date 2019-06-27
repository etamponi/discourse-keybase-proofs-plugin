# frozen_string_literal: true

require 'rails_helper'

describe KeybaseProofs::ConfigController do  
  before do
    Jobs.run_immediately!
  end
  
  describe "GET /keybase-proofs/config" do

    it "returns a Keybase configuration" do
      get "/keybase-proofs/config"

      assert(response.status).to eq(200)
    end

  end

end
