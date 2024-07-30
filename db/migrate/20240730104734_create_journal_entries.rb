class CreateJournalEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :journal_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :credit_title, null: false
      t.string :debit_title, null: false
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
