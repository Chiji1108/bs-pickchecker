class Battle < ApplicationRecord
  belongs_to :event
  belongs_to :battle_type
  validates :event, presence: true
  validates :battle_type, presence: true

  has_many :picks
  has_many :accounts, through: :picks
  has_many :teams, through: :picks
  has_many :brawlers, through: :picks

  validates :time, presence: true
  validates :time_code, presence: true
  validates :duration, presence: true

  # validates :id, uniqueness: {scope: [:event, :battle_type, :time, :time_code, :duration]}

  def getTeamByAccount(account)
    self.teams.each do |t|
      t.accounts.each do |a|
        if(account == a)
          return t
        end
      end
    end
  end

  def getOpponentTeamsByAccount(account)
    teams = self.teams
    teams.delete(self.getTeamByAccount(account))
    teams
  end
end
