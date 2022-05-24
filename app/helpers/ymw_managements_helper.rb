module YmwManagementsHelper

  def study_hour_sum(item) # _years_complete_list.htmlから呼ばれている
    first_day = item.begin_day
    second_day = item.finish_day
    worked_days = @user.managements.where(worked_on: first_day..second_day)
    study_hour = []
    worked_days.each do |item|
      if item.study_time == nil
        item.study_time = 0
      end
      study_hour << item.study_time
    end
    return study_hour.sum
  end

  def ymw_study_time(item) # complite_list.htmlの年月週の累計時間から呼び出し
    # 年間勉強時間
    ymw_study_time = []
    ymw_span = [*item.begin_day..item.finish_day]
    ymw_items = @user.managements.where(worked_on: ymw_span)
    ymw_items.all.each do |ymw_item|
      if ymw_item.study_time == nil
        ymw_item.study_time = 0
      end
      ymw_study_time << ymw_item.study_time 
    end
    return ymw_study_time.sum
  end

end
