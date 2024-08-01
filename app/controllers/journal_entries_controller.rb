class JournalEntriesController < ApplicationController
  include Secured

  def index
    @user = User.find_by(email: session[:userinfo]["email"])
    @journal_entries = @user.journal_entries
    @journal_entry = JournalEntry.new # indexページで登録も行うため
  end
end
