class JournalEntry < ApplicationRecord
  belongs_to :user

  validates :credit_title, presence: true
  validates :debit_title, presence: true
  validates :amount, presence: true
end
