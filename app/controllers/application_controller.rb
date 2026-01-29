class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authorize

  protected

  # Gracefully handle attempted deletes that are blocked by FK/dependent restrictions
  rescue_from ActiveRecord::DeleteRestrictionError do |ex|
    redirect_back fallback_location: root_path, alert: "Cannot delete record because it is referenced elsewhere: #{ex.message}"
  end

  def authorize
    unless @user = User.find_by(:id => session[:user_id])
      redirect_to login_url, :notice => "Please log in!"
    end
  end
end
