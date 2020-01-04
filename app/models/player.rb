class Player < ApplicationRecord
  has_many :accounts, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def to_param
    name
  end
end
