class Pick < ApplicationRecord
  belongs_to :account
  belongs_to :brawler
  belongs_to :team
end
