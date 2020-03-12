class Battle < ApplicationRecord
  belongs_to :event
  belongs_to :battle_type
  validates :event, presence: true
  validates :battle_type, presence: true

  has_many :picks
  has_many :accounts, through: :picks
  has_many :teams, -> { distinct }, through: :picks
  has_many :brawlers, through: :picks
  has_many :access_histories

  validates :time, presence: true
  validates :time_code, presence: true

  # validates :id, uniqueness: {scope: [:event, :battle_type, :time, :time_code, :duration]}, allow_nil: true

  def team_with(account)
    # self.teams.each do |t|
    #   t.accounts.each do |a|
    #     if(account == a)
    #       return t
    #     end
    #   end
    # end
    self.teams.includes(:accounts).find_by(accounts: {id: account.id})
  end

  def pick_with(account)
    # self.picks.each do |pick|
    #   if(pick.account == account)
    #     return pick
    #   end
    # end
    self.picks.find_by(account_id: account.id)
  end

  def teams_opponent_with(account)
    self.teams.includes(:accounts).where.not(teams: {id: self.team_with(account).id})
    # teams = self.teams.dup
    # teams.delete(self.getTeamByAccount(account))
    # teams
  end
end
