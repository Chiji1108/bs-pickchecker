class Event < ApplicationRecord
  belongs_to :mode
  belongs_to :map
  validates :mode, presence: true
  validates :map, presence: true
  
  has_many :battles, dependent: :destroy

  validates :bs_id, presence: true, uniqueness: true
end
