class UsersController < ApplicationController

  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    credentials = request.env['omniauth.auth']['credentials']
    token = credentials["token"]
    expires = credentials["expires_at"]

    @user = User.new
    @user.token = token
    @user.expires = Time.at(expires)

    # add token to user
    # add expire to user
    # use @user credientials to pass to User.koala(auth)
    fbuser = User.koala(credentials) #fbid #picture
    #retrieve any potential profile data we can use to populate signup form

    unless fbuser["email"].nil?
      @user.email = fbuser["email"]
    end

    @user.name = fbuser["name"]
    @user.facebook_id = fbuser["id"]
    @user.picture = fbuser["picture"]["data"]["url"].to_s
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    @user.token = params["token"]
    @user.facebook_id = params["facebook_id"]
    @user.expires = params["expires"]
    @user.picture = params["picture"]
    if @user.save
       @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :token, :facebook_id, :expires, :picture)
    end

    # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
