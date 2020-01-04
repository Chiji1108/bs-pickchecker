class Pick < ApplicationRecord
  belongs_to :account
  belongs_to :brawler
  belongs_to :team

  has_many :pick_battle_histories, dependent: :destroy
  has_many :battles, through: :pick_battle_histories

  validates :account, presence: true, uniqueness: { scope: [:brawler, :team] }
  validates :brawler, presence: true
  validates :team, presence: true
end
