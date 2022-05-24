class Management < ApplicationRecord
  belongs_to :user

  validates :day_p, length: { maximum: 200 }
  validates :day_d, length: { maximum: 200 }
  validates :day_c, length: { maximum: 200 }
  validates :day_a, length: { maximum: 200 }

  # validates :study_time, allow_blank: true # numericality: true, 
  validate :time_based
		
  def time_based
    if study_time.present?
      # 記号や文字列は0.0になるため
      if study_time == 0.0
        errors.add(:study_time, "は数字で0.25単位(15分単位)で入力してください")
      end
      # if study_time.is_a?(Numeric)
      time = study_time.to_s.split('.')
      unless time[1].in?(["0", "25", "5", "75"])
        errors.add(:study_time, "は0.25単位(15分単位)で入力してください")
      end
    end
  end
end


