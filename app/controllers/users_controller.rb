# coding: utf-8
class UsersController < ApplicationController
  def index
    @users = User.all
  end
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.encrypt_password
    @user.last_login = Time.now

    #render :json => @user

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, :notice => "joined successfully" }
        format.json { render json: @users, status: :created, location: @user }
      else
        format.html { render 'new', :notice => @user.errors.full_messages}
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def login_attempt
    authorized_user = User.authenticate(params[:ogame_id],params[:password])
    session[:last_seen] = Time.now
    if authorized_user
      session[:user_id] = authorized_user.id
      redirect_to planets_path
    else
      flash[:notice] = "Invalid Username or Password"
      session[:user_id] = nil
      redirect_to :back
    end
  end

end
