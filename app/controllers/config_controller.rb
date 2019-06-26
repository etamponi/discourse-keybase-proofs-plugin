# frozen_string_literal: true

module KeybaseProofs

  class ConfigController < ApplicationController

    skip_before_action :check_xhr

    def index
      render json: success_json
    end

  end
  
end
