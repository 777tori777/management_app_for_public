module ApplicationHelper
  def full_title(page_name = "")
    base_title = "PDCA管理アプリ"
    if page_name.empty?
      base_title
    else
      page_name + " | " + base_title
    end
  end

  def span(day_span)
    if day_span == '0.年間'
      return '年間'
    elsif day_span == '1.月間'
      return '月間'
    else
      return '週間'
    end
  end

  # ymw_span = ['0.年間', '1.月間', '2.週間']
  def pdca_value(item, pdca)    
    if item.span == '0.年間'
      if pdca == 'p'
        item.year_p
      elsif pdca == 'd'
        item.year_d
      elsif pdca == 'c'
        item.year_c
      else
        item.year_a
      end
    elsif item.span == '1.月間'
      if pdca == 'p'
        item.month_p
      elsif pdca == 'd'
        item.month_d
      elsif pdca == 'c'
        item.month_c
      else
        item.month_a
      end
    else
      if pdca == 'p'
        item.week_p
      elsif pdca == 'd'
        item.week_d
      elsif pdca == 'c'
        item.week_c
      else
        item.week_a
      end
    end
  end

  # 全メンバーの、年、月、週の平均勉強時間を計算
  def average_data(number)
    if number == 0
      first_day = Date.current.beginning_of_year
      last_day = Date.current.end_of_year
    elsif number == 1
      first_day = Date.current.beginning_of_month
      last_day = Date.current.end_of_month
    else
      first_day = Date.current.beginning_of_week
      last_day = Date.current.end_of_week
    end
 
    @users = User.where.not(admin: true).where(status: "approval")
    all_worked_days = []
    all_member_study_hour = []

    @users.each do |user|
      user_work_days = user.managements.where(worked_on: first_day..last_day)
                                        .where.not(study_time: nil) # nilを外す
      study_hour = []
      user_work_days.each do |item|
        if item.study_time == nil
          item.study_time = 0.0
        end
        study_hour << item.study_time
      end
      all_member_study_hour << study_hour.sum
    end
    return all_member_study_hour.sum / @users.count
  end

  def find_name(id)
    return User.find(id).name
  end

end
