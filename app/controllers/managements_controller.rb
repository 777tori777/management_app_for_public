class ManagementsController < ApplicationController

  # params[:user_id]の箇所　idでとろうとすると違った値になる
  # binding.pryでparamsを取ると、Parameters: {"user_id"=>"2", "id"=>"3"}
  def edit
    @user = User.find(params[:user_id])
    @management = Management.find(params[:id])
  end
    
  def update
    @user = User.find(params[:user_id]) # redirect_toで利用
    @management = Management.find(params[:management_id])
    if @management.update_attributes(day_management_params)
      redirect_to user_path(@user, date: @management.worked_on.beginning_of_month)
      flash[:success] = '情報を更新しました'
    elsif @management.errors.present?
      flash[:danger] = "更新に失敗しました<br>" + @management.errors.full_messages.join("<br>")
      redirect_to user_path(@user, date: @management.worked_on.beginning_of_month)
    end 
  end
end

private
  def day_management_params
    params.permit(:study_time, :day_p, :day_d, :day_c, :day_a) # 1件しか飛んでこないので、配列にする必要はない
  end


