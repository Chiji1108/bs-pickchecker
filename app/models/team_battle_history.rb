class TeamBattleHistory < ApplicationRecord
  belongs_to :team
  belongs_to :battle

  validates :team, presence: true
  validates :battle, presences: true
  
  validates :id, uniqueness: {scope: [:team, :battle, :result]}
end
