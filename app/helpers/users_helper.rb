module UsersHelper  
  # 累計勉強時間はymw_managements_helperに記載
  def user_status(status)
    if status == "approval"
      return "承認済み"
    elsif status == "repudiationl"
      return "repudiationl"
    else
      return "applying"
    end
  end
end



