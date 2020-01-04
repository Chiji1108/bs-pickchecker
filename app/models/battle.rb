class Battle < ApplicationRecord
  belongs_to :event
  belongs_to :battle_type
end
