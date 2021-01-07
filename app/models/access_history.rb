class AccessHistory < ApplicationRecord
  belongs_to :account
  belongs_to :battle

  validates :id, uniqueness: {scope: [:account, :battle]}
end
