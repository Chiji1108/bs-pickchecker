class Pick < ApplicationRecord
  belongs_to :battle
  belongs_to :account
  belongs_to :brawler
  belongs_to :team
  validates :battle, presence: true
  validates :account, presence: true
  validates :brawler, presence: true
  validates :team, presence: true
end