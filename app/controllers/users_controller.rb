# coding: utf-8
class UsersController < ApplicationController
  before_filter :save_login_state, :only => [:new, :create, :index]
  before_filter :authenticate_user, :only => [:show, :edit]

  def index
    @users = User.all
  end
  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
    if @user.id == session[:user_id]
      @is_me = true
    end
  end

  def create
    user = User.new(params[:user])
    if User.where(:ogame_id => user, :password => nil).first
      @user = User.where(:ogame_id => user, :password => nil).first
      @user.password = user.password
      @user.password_confirmation = user.password_confirmation
    else
      @user = user
    end

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

  def update
    @user = User.find(params[:id])

    status = ""
    params[:status].each do |k, v|
      if v == "1"
        status += k + ","
      end
    end

    @user.status = status
    @user.save

    redirect_to :back
    #render :json => @user
  end

  def login_attempt
    authorized_user = User.authenticate(params[:ogame_id],params[:password])
    session[:last_seen] = Time.now
    if authorized_user
      session[:user_id] = authorized_user.id
      #redirect_to planets_path
      redirect_to edit_user_path(authorized_user)
    else
      flash[:notice] = "Invalid Username or Password"
      session[:user_id] = nil
      redirect_to :back
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to :planets }
      format.json { head :no_content }
    end
  end

end
