# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    
    include Api::Authenticatable

    before_action :authenticate_http_basic_auth!
  end
end
