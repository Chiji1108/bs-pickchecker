class Team < ApplicationRecord
  has_many :picks
  has_many :accounts, through: :picks
  has_many :brawlers, through: :picks
  has_many :battles, through: :picks
end
