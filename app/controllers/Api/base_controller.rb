# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_user!

    private

    def authenticate_user!
      @current_user = authenticate_with_http_basic do |username, password|
        User.find_by(username:)&.authenticate(password)
      end

      render json: { error: 'Invalid credentials' }, status: :unauthorized if @current_user.nil?
    end
  end
end
