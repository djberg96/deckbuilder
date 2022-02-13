class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
    if User.find_by(:username => params[:username])
      redirect_to decks_url, :alert => "Welcome to the Deckbuilder #{params[:username]}"
    end
  end

  def create
    user = User.find_by(:username => params[:username])
    if user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      redirect_to decks_url
    else
      redirect_to login_url, :alert => "Invalid username/password combination"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url, :notice => "Logged out"
  end
end
