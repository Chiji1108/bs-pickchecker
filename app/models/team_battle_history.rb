class TeamBattleHistory < ApplicationRecord
  belongs_to :team
  belongs_to :battle
end
