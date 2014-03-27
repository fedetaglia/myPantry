class ShoppingList < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true
  validates :aggregator, presence: true
  validates :ingredients, presence: true

end
