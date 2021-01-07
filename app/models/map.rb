class Map < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :modes, through: :events

  validates :name, presence: true, uniqueness: true
end
