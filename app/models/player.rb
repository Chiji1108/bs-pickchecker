class Player < ApplicationRecord
  has_many :accounts, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  def to_param
    name
  end

  def self.names
    result = []
    Player.all.each do |player|
      result.push(player.name)
    end
    result
  end

end
