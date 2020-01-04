class Event < ApplicationRecord
  belongs_to :mode
  belongs_to :map
  has_many :battles, dependent: :destroy

  validates :bs_id, presence: true, uniqueness: true
  validates :mode, presence: true
  validates :map, presence: true
end
