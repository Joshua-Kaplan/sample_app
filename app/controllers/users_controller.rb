class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index] 
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :if_signed_in, only: [:new, :create]

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

	def show
		@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
	end

  def new
  	@user = User.new
  end 

  def create
  	@user = User.new(user_params)
  	if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App"
      redirect_to @user
  	else
  		render 'new'
  	end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if current_user?(@user)
     
      redirect_to users_url, notice: "You cannot delete your own profile."
    else
      @user.destroy
      flash[:success] = "User deleted."
      redirect_to users_url
    end
  end

  def feed
    Micropost.where("user_id = ?", id)
  end

  private

  def user_params
  	params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  #Before filters

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def if_signed_in
    redirect_to user_path(current_user), notice: "You are currently signed in as #{current_user.name}!" if signed_in?
  end

end
