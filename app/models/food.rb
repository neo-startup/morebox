class Food < ApplicationRecord
  mount_uploader :image, ImageUploader
  has_many :food_sub_items, dependent: :nullify
  has_many :sub_items, through: :food_sub_items

  #a b c d e는 spare_calorie(목표 섭취 칼로리 - 점심 칼로리)값이 적은 순대로
  enum food_type: %i(a b c d)
end

