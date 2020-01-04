class Brawler < ApplicationRecord
  has_many :picks, dependent: :destroy
  has_many :accounts, through: :picks

  validates :bs_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
end
