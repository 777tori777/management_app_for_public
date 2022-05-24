class YmwManagementsController < ApplicationController
  
  # 定数
  UPDATE_ERROR_MSG = '失敗したため、やり直してください'
  
  # ymw_span = ['0.年間', '1.月間', '2.週間']
  def complete_list  # years_complete_listで、モーダルで使うつもりだったが通常のページに変更
    @user = User.find(params[:user_id])
    if YmwManagement.find(params[:format]).span == '0.年間'
      @show_ymw_managements = YmwManagement.where(span: '0.年間')
      .where(finish_flag: true)
      .where(user_id: @user.id)
      .order(finish_day: :desc)
      .paginate(page: params[:page], per_page: 5)
      @name = '年間'
    elsif YmwManagement.find(params[:format]).span == '1.月間'
      @show_ymw_managements = YmwManagement
      .where(span: '1.月間')
      .where(finish_flag: true)
      .where(user_id: @user.id)
      .order(finish_day: :desc)
      .paginate(page: params[:page], per_page: 5)
      @name = '月間'
    else
      @show_ymw_managements = YmwManagement
      .where(span: '2.週間')
      .where(finish_flag: true)
      .where(user_id: @user.id)
      .order(finish_day: :desc)
      .paginate(page: params[:page], per_page: 5)
      @name = '週間'
    end    
  end

  ymw_span = ['0.年間', '1.月間', '2.週間']

  # 完了が、updateで動く
  def update
    @user = User.find(params[:user_id])
    @ymw_management = YmwManagement.find(params[:ymw_management_id])
    if @ymw_management.span == '0.年間'
      if @ymw_management.begin_day.blank? || @ymw_management.finish_day.blank? || 
      @ymw_management.year_p.blank? || @ymw_management.year_d.blank? || 
      @ymw_management.year_c.blank? || @ymw_management.year_a.blank?
        flash[:danger] = "完了するには開始日、終了日、P、D、C、Aを全て入力してください。"
        redirect_to @user
      else
        @ymw_management.update_attributes(finish_flag: true)
        flash[:info] = '完了に変更しました！'
        redirect_to @user
      end
    elsif @ymw_management.span == '1.月間'
      if @ymw_management.begin_day.blank? || @ymw_management.finish_day.blank? || 
      @ymw_management.month_p.blank? || @ymw_management.month_d.blank? || 
      @ymw_management.month_c.blank? || @ymw_management.month_a.blank?
        flash[:danger] = "完了するには開始日、終了日、P、D、C、Aを全て入力してください。"
        redirect_to @user
      else
        @ymw_management.update_attributes(finish_flag: true)
        flash[:info] = '完了に変更しました！'
        redirect_to @user
      end
    else
      if @ymw_management.begin_day.blank? || @ymw_management.finish_day.blank? || 
      @ymw_management.week_p.blank? || @ymw_management.week_d.blank? || 
      @ymw_management.week_c.blank? || @ymw_management.week_a.blank?
        flash[:danger] = "完了するには開始日、終了日、P、D、C、Aを全て入力してください。"
        redirect_to @user
      else
        @ymw_management.update_attributes(finish_flag: true)
        flash[:info] = '完了に変更しました！'
        redirect_to @user
      end
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @ymw_management = YmwManagement.find(params[:id])
  end

  # 情報の更新は、update_ymw_completeに割り当てられている
  def update_ymw_complete # routingが変わり、updateアクションは別で割り当てた
    @user = User.find(params[:user_id])
    @ymw_management = YmwManagement.find(params[:id])
    if @ymw_management.update_attributes(ymw_management_params)
      flash[:success] = '情報を更新しました'
      redirect_to user_path(@user)
    else
      flash[:danger] = "更新に失敗しました<br>" + @ymw_management.errors.full_messages.join("<br>")
      # render :_edit
      redirect_to user_path(@user)
    end
    
  end

  def destroy
    @ymw_management = YmwManagement.find(params[:id])
    user_id = @ymw_management.user_id
    @ymw_management.destroy
    flash[:danger] = '情報を削除しました'
    redirect_to user_path(user_id) 
  end
end

private
  def ymw_management_params
    params.permit(:begin_day,
      :finish_day,
      :finish_flag,
      :year_p,
      :year_d,
      :year_c,
      :year_a,
      :month_p,
      :month_d,
      :month_c,
      :month_a,
      :week_p,
      :week_d,
      :week_c,
      :week_a,
      :user_id,
      ) # 1件しか飛んでこないので、配列にする必要はない
  end




