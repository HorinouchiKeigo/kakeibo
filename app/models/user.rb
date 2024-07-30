class User < ApplicationRecord
  has_many :journal_entries

  validates :auth0_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
