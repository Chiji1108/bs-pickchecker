class Team < ApplicationRecord
  has_many :team_battle_histories, dependent: :destroy
  has_many :battles, through: :team_battle_histories
  has_many :picks, dependent: :destroy
  has_many :accounts, through: :picks
  has_many :brawlers, through: :picks

  validates :picks, uniqueness: true
end
