class Battle < ApplicationRecord
  belongs_to :event
  belongs_to :battle_type

  has_many :team_battle_histories, dependent: :destroy
  has_many :teams, through: :team_battle_histories
  has_many :pick_battle_histories, dependent: :destroy
  has_many :picks, through: :pick_battle_histories

  validates :event, presence: true
  validates :battle_type, presence: true

  validates :id, uniqueness: {scope: [:event, :battle_type, :time, :duration]}
end
