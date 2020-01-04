class Account < ApplicationRecord
  belongs_to :player, optional: true
  has_one :profile, dependent: :destroy
  has_many :picks, dependent: :destroy
  has_many :brawlers, through: :picks
  has_many :teams, through: :picks

  validates :tag, presence: true, uniqueness: true

  def tag=(val)
    self[:tag] = val.upcase
  end

  def to_param
    tag
  end

  NOTE = ["メインアカウント", "サブアカウント", "その他"]
end
