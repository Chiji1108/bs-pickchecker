class BattleType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
