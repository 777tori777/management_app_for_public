class YmwManagement < ApplicationRecord
  belongs_to :user

  validates :year_p, length: { maximum: 200 }
  validates :year_d, length: { maximum: 200 }
  validates :year_c, length: { maximum: 200 }
  validates :year_a, length: { maximum: 200 }

  validates :month_p, length: { maximum: 200 }
  validates :month_d, length: { maximum: 200 }
  validates :month_c, length: { maximum: 200 }
  validates :month_a, length: { maximum: 200 }

  validates :week_p, length: { maximum: 200 }
  validates :week_d, length: { maximum: 200 }
  validates :week_c, length: { maximum: 200 }
  validates :week_a, length: { maximum: 200 }

  validate :start_finish_day
  def start_finish_day
    if begin_day.present? && finish_day.present?
      if begin_day > finish_day
        errors.add(:begin_day, "、終了日を正しく入力してください")
      end
    end
  end
end
