class Recipe < ActiveRecord::Base
  validates :name, presence: true
  validates :yummly_id, presence: true
  validates :value, presence: true

end