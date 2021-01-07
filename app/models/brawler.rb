class Brawler < ApplicationRecord
  has_many :picks, dependent: :destroy
  has_many :accounts, through: :picks
  has_many :brawler, through: :picks

  validates :bs_id, presence: true, uniqueness: true
  validates :name, presence: true
end
