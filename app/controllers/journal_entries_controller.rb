class JournalEntriesController < ApplicationController
  include Secured

  def index
    @user = User.find_by(email: session[:userinfo]["email"])
  end
end
