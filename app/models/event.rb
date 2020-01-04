class Event < ApplicationRecord
  belongs_to :mode
  belongs_to :map

  validates :bs_id, presence: true, uniqueness: true
end
