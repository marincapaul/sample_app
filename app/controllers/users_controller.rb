class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create 
    
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Greetings fellow sample man!"
      redirect_to @user
    else
      render 'new'
    end

  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :password, 
                                  :password_confirmation)
    end
end
