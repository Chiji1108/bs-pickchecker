class PickBattleHistory < ApplicationRecord
  belongs_to :pick
  belongs_to :battle
end
