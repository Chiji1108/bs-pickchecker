class Mode < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :maps, through: :events

  validates :name, presence: true, uniqueness: true
end
