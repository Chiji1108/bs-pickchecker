class PickBattleHistory < ApplicationRecord
  belongs_to :pick
  belongs_to :battle

  validates :pick, presence: true
  validates :battle, presence: true

  validates :id, uniqueness: {scope: [:pick, :battle, :trophies, :trophy_change, :is_mvp]}
end
