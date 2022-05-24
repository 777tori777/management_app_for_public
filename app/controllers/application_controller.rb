class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # slackのWEBHOOK_URLが必要
  WEBHOOK_URL = '"#"'

  include SessionsHelper

    # グローバル変数 %w{日 月 火 水 木 金 土}はRubyのリテラル表記、"の記述が不要なので記述がとてもシンプル
    # ["日", "月", "火", "水", "木", "金", "土"]の配列と同じように使える
  $days_of_the_week = %w{日 月 火 水 木 金 土}

   # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
  end

  def user_status_confirmation_others
    if logged_in?
      if current_user.status != "approval" # ユーザー未承認の場合      
        if current_user.admin == true
          flash[:danger] = "ユーザーが承認されていないため、情報を表示できません"
          redirect_to users_path
        else
          flash[:danger] =  "ユーザーが承認されていないため、情報を表示できません"
          redirect_to user_path(current_user)
        end
      end
    else
      flash[:danger] = "ログインしてください"
      redirect_to root_path
    end
  end

  def user_status_confirmation_users_data
    if logged_in?
      if current_user.status != "approval"
        flash[:danger] = "ユーザーが未登録か承認されていないため、情報を表示できません"
        redirect_to root_path
      end
    else
      flash[:danger] = "ログインしてください"
      redirect_to root_path
    end
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
    # current_user?(@user)はsessions_helprerを呼んでいる
    # 引数は@user @userがapplication_controllerのset_userで定義されている
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end

    # システム管理権限所有かどうか判定
  def admin_user
    unless current_user.admin?
      flash[:danger] = "閲覧には管理者権限が必要です。"
      redirect_to root_url
    end
  end

    # ページ出力前に1ヶ月分のデータの存在を確認・セット
  def set_one_month
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
      # one_monthを定義 対象の月の日数を配列化
        # 配列として扱う書き方　[*@first_day..@last_day] 
        # 範囲オブジェクトとして扱う書き方(@first_day..@last_day)
    one_month = [*@first_day..@last_day]
      # ユーザーに紐付く一ヶ月分のレコードを検索し取得　@userはdef set_userでidを定義されている
    @managements = @user.managements.where(worked_on: @first_day..@last_day).order(:worked_on)
    # それぞれの件数（日数）が一致するか評価
      # @first_dayと@last_dayを引っ張っているのに違うことある？ いずれにせよmanagementsを生成
    unless one_month.count == @managements.count 
        # トランザクションを開始します。
          #指定したブロックにあるデータベースへの操作が全部成功することを保証する為の機能
          # データの整合性を保つために使用されています。
          # 例外が発生した場合はrescueに飛ぶ
      ActiveRecord::Base.transaction do 
        # 繰り返し処理により、1ヶ月分の勤怠データを生成
        # !がついたメソッドは中身を変更することを表す。
        one_month.each { |day| @user.managements.create!(worked_on: day) }
      end
    @managements = @user.managements.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
    # トランザクションによるエラーの分岐
     #勤怠データが期待通りに生成できずcreate!メソッドが例外を吐き出した時に、
     #この繰り返し処理が始まる前の状態のデータベースに戻る
  rescue ActiveRecord::RecordInvalid 
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end

  def set_ymw
    @user = User.find(params[:id])
    if @user.ymw_managements.count == 0
      ymw_span = ['0.年間', '1.月間', '2.週間']
      ymw_span.each { |item| @user.ymw_managements.create!(span: item) }
      @ymw_managements = @user.ymw_managements
    else
      @ymw_managements = @user.ymw_managements.where.not(span: nil)
                          .where.not(finish_flag: true)
                          .order(:span)
      if @ymw_managements.count == 2
        items = []
        items_id = []
        @ymw_managements.each do |ymw|
          items << ymw.span
          items_id << ymw.id
        end
        if items.include?('1.月間') & items.include?('2.週間')
          ymw = @user.ymw_managements.create!(span: '0.年間')
        elsif items.include?('0.年間') & items.include?('2.週間')
          ymw = @user.ymw_managements.create!(span: '1.月間')
        else
          ymw = @user.ymw_managements.create!(span: '2.週間')
        end
        items_id << ymw.id
        @ymw_managements = YmwManagement.where(id: items_id[0])
                                          .or(YmwManagement.where(id: items_id[1]))
                                          .or(YmwManagement.where(id: items_id[2]))
                                          .order(:span) 
      else
        @ymw_managements.order(:span)
      end
    end
  end
  
    # users_controllerから、application_controllerに移動
    # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    # sessions_helper
    unless current_user?(@user) || current_user.admin? || current_user.superior?
      flash[:danger] = "閲覧権限がありません。"
      # redirect_to @user
      redirect_to user_path(current_user.id)
    end  
  end


    # 全メンバーの、年の平均勉強時間を計算
    # ログインしていないと、work_onができないため、数がおかしい
    # 数が存在しているものの平均となる
    # 0、または1とか、ページが開かれて、IDが存在するものの平均　nilは0になる
  def year_data   
    year_first_day = Date.current.beginning_of_year
    year_last_day = Date.current.end_of_year

    # ユーザーと年間累計勉強時間のハッシュ
    year_user_study_hours = {}
    # 管理者を除く
    @users = User.where.not(admin: true)
    @users.each do |user|
      user_study_hour = [] # userが回転するごとに初期化する必要がある 
      # userごと、managementsモデルの該当期間のデータを取得 
      user_year_items = user.managements.where(worked_on: year_first_day..year_last_day)
      # ユーザーごとの、年の勉強時間の配列      
      user_year_items.each do |item|
        if item.study_time == nil
          item.study_time = 0.0
        end
        user_study_hour << item.study_time
      end

      # 配列から合計に変更し、変数に入力
      # 累計時間とユーザーの名前を取得
      user_study_hour_time = user_study_hour.sum
      # ハッシュ 累計勉強時間とユーザーid
      unless user_study_hour_time == 0 # 最後のユーザーのみ、なぜか"0"のハッシュができてしまうためunless文を設置
        year_user_study_hours.store(user_study_hour_time, user.id)
      end
    end
      # ユーザーごとの、年の勉強時間を、降順で配列化
    @year_user_study_hours = year_user_study_hours.sort.reverse
  end

    # 全メンバーの、年の平均勉強時間を計算
    def month_data   
      month_first_day = Date.current.beginning_of_month
      month_last_day = Date.current.end_of_month
  
      # ユーザーと年間累計勉強時間のハッシュ
      month_user_study_hours = {}
      @users = User.where.not(admin: true)
  
      @users.each do |user|
        user_study_hour = [] # userが回転するごとに初期化する必要がある 
        # userごと、managementsモデルの該当期間のデータを取得
        user_month_items = user.managements.where(worked_on: month_first_day..month_last_day)
        # ユーザーごとの、年の勉強時間の配列
        
        user_month_items.each do |item|
          if item.study_time == nil
            item.study_time = 0.0
          end
          user_study_hour << item.study_time
        end
        # 配列から合計に変更し、変数に入力
        # 累計時間とユーザーの名前を取得
        user_study_hour_time = user_study_hour.sum  
        # ハッシュ 累計勉強時間とユーザーid
        unless user_study_hour_time == 0 # 最後のユーザーのみ、なぜか"0"のハッシュができてしまうためunless文を設置
          month_user_study_hours.store(user_study_hour_time, user.id)
        end
      end
        # ユーザーごとの、勉強時間を、降順で配列化
      @month_user_study_hours = month_user_study_hours.sort.reverse
    end

  # 全メンバーの、年の平均勉強時間を計算
  def week_data   
    week_first_day = Date.current.beginning_of_week
    week_last_day = Date.current.end_of_week

    # ユーザーと年間累計勉強時間のハッシュ
    week_user_study_hours = {}
    @users = User.where.not(admin: true)

    @users.each do |user|
      user_study_hour = [] # userが回転するごとに初期化する必要がある 
      # userごと、managementsモデルの該当期間のデータを取得
      user_week_items = user.managements.where(worked_on: week_first_day..week_last_day)
      # ユーザーごとの、年の勉強時間の配列
      
      user_week_items.each do |item|
        if item.study_time == nil
          item.study_time = 0.0
        end
        user_study_hour << item.study_time
      end
      # 配列から合計に変更し、変数に入力
      # 累計時間とユーザーの名前を取得
      user_study_hour_time = user_study_hour.sum
      # ハッシュ 累計勉強時間とユーザーid
      unless user_study_hour_time == 0 # 最後のユーザーのみ、なぜか"0"のハッシュができてしまうためunless文を設置
        week_user_study_hours.store(user_study_hour_time, user.id)
      end
    end
      # ユーザーごとの、勉強時間を、降順で配列化
    @week_user_study_hours = week_user_study_hours.sort.reverse
  end
end

