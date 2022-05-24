class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :user_status_confirmation_others, only: [:show, :edit, :update, :destroy]
  before_action :user_status_confirmation_users_data, only: [:index, :users_data]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :set_one_month, only: :show
  before_action :set_ymw, only: :show

  def index
    if current_user.admin? 
      @user = User.find(current_user.id)
      @users = User.paginate(page: params[:page])

      @user_status_number = User.where(status: "applying").count
    else
      flash[:danger] = "ユーザー一覧を見るには管理者権限が必要です"
      redirect_to user_path(current_user.id)
    end
  end

  def show # show.htmlの年月週の累計時間から呼び出し    
    # 年間勉強時間
    one_year_study_time = []
    one_year = [*Date.current.beginning_of_year..Date.current.end_of_year]
    @ont_year_managements = @user.managements.where(worked_on: one_year)
    @ont_year_managements.all.each do |item|
      if item.study_time == nil
        item.study_time = 0
      end
      one_year_study_time << item.study_time 
    end
    @one_year_study_time = one_year_study_time.sum
    # 月間勉強時間
    one_month_study_time = []
    one_month = [*Date.current.beginning_of_month..Date.current.end_of_month]
    @ont_month_managements = @user.managements.where(worked_on: one_month)


    @ont_month_managements.all.each do |item|
      if item.study_time == nil
        item.study_time = 0
      end
      one_month_study_time << item.study_time 
    end
    @one_month_study_time = one_month_study_time.sum
    # 週間勉強時間
    one_week_study_time = []
    one_week = [*Date.current.beginning_of_week..Date.current.end_of_week]
    @ont_week_managements = @user.managements.where(worked_on: one_week)
    @ont_week_managements.all.each do |item|
      if item.study_time == nil
        item.study_time = 0
      end
      one_week_study_time << item.study_time 
    end
    @one_week_study_time = one_week_study_time.sum
  end

  def new
    @user = User.new
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    user_name = @user.name
    flash[:success] = "#{user_name}を削除しました"
    Slack::Notifier.new(WEBHOOK_URL, username: '通知Bot', icon_emoji: ':skull:')
    .ping("#{user_name}を削除しました")
    redirect_to users_path
  end

  # 全メンバーの、年、月、週の平均勉強時間を計算
  def users_data # application_controllerから呼び出し
    year_data
    month_data
    week_data
  end

  def create
    @user = User.new(user_params)
    user_name = @user.name
    if @user.save
      flash[:success] = 'ユーザー登録しました <br>
      承認されるまでお待ちください'
      Slack::Notifier.new(WEBHOOK_URL, username: '通知Bot', icon_emoji: ':sunglasses:')
      .ping("#{user_name}よりユーザー登録がありました
        承認作業をしてください")
      redirect_to root_path
    else      
      flash.now[:danger] = 'ユーザーの作成に失敗しました' 
      Slack::Notifier.new(WEBHOOK_URL, username: '通知Bot', icon_emoj: ':sweat_drops:')
      .ping("ユーザー登録の失敗がありました")
      render :new
    end    
  end

  def approve_user
    @user = User.find(params[:id])
    @user.update_attributes(status: "approval")
    user_name = @user.name
    flash[:success] = "#{user_name}を承認しました"
    Slack::Notifier.new(WEBHOOK_URL, username: '通知Bot', icon_emoji: ':sunglasses:')
    .ping("#{user_name}を承認しました")
    redirect_to users_path
  end

  def deny_user    
    @user = User.find(params[:id])
    @user.update_attributes(status: "repudiationl")
    user_name = @user.name
    flash[:danger] = "#{user_name}を否認しました"
    Slack::Notifier.new(WEBHOOK_URL, username: '通知Bot', icon_emoji: ':dizzy_face:')
    .ping("#{user_name}を否認しました")
    redirect_to users_path
  end

  def edit_canfirmation_application # 使用中
    @users = User.where(status: "applying")
  end
  
end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # beforeフィルター  # paramsハッシュからユーザーを取得
    def set_user
      @user = User.find(params[:id])
    end

    # ログイン済みのユーザーか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end

    # アクセスしたユーザーが現在ログインしているユーザーか確認
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
    end

    # システム管理権限所有かどうか判定します。
    def admin_user
      redirect_to root_url unless current_user.admin?
    end

    
