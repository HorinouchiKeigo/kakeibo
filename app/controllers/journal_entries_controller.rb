class JournalEntriesController < ApplicationController
  include Secured

  def index
    set_user
    @journal_entries = @user.journal_entries
    @journal_entry = JournalEntry.new # indexページで登録も行うため
  end
  private

  def set_user
    @user = User.find_by(email: session[:userinfo]["email"])
  end
end
