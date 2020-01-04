class Profile < ApplicationRecord
  belongs_to :account

  validates :account, presence: true, uniqueness: true
end
