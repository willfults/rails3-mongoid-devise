class ApplicationController < ActionController::Base
  include ApplicationHelper
  include DeviseHelper

  protect_from_forgery

  before_filter :http_authenticate if Rails.env.production?

  def after_sign_in_path_for(resource)
    if session[:add_auth_service] && session[:add_auth_service] == 'linkedin'
      session[:add_auth_service] = nil
      '/auth/linkedin'
    elsif ( current_user.role == "creator" )
      stored_location_for(resource) || dashboard_user_path(current_user)
    elsif ( current_user.role == "user" )
      stored_location_for(resource) || my_courses_path
    else
      super
    end
  end

  def is_course_creator?
    if current_user.nil? || ! current_user.is_course_creator?
      redirect_to destroy_user_session_path
    end
  end

  def http_authenticate
    if request.domain != 'localhost'
      authenticate_or_request_with_http_basic do |username, password|
         username == "socialu" && password == "s0cia1u"
      end
      warden.custom_failure! if performed?
    end
  end
end
