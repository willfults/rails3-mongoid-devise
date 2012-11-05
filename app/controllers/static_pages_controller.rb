
class StaticPagesController < ApplicationController

  def home
    if user_signed_in?
      if current_user.avatar? 
        @avatar = Avatar.find(current_user.avatar)
      end
      redirect_to current_user
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
