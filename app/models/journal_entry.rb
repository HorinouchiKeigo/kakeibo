class JournalEntry < ApplicationRecord
  belongs_to :user

  validates :credit_title, presence: true # 貸方
  validates :debit_title, presence: true # 借方
  validates :amount, presence: true
end
