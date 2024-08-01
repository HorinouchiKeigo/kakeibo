class JournalEntriesController < ApplicationController
  include Secured

  def index
    set_user
    @journal_entries = @user.journal_entries.order(created_at: :desc)
    @journal_entry = @user.journal_entries.new # indexページで登録も行うため
  end

  def create
    set_user
    @journal_entry = @user.journal_entries.new(journal_entry_params)

    if @journal_entry.save
      flash[:notice] = "仕訳を保存しました"
      redirect_to journal_entries_path
    else
      @journal_entries = @user.journal_entries.order(created_at: :desc)
      flash.now[:alert] = "仕訳の保存に失敗しました"
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    set_user
    @journal_entry = @user.journal_entries.find(params[:id])
    @journal_entry.destroy
    flash[:notice] = "仕訳を削除しました"
    redirect_to journal_entries_path

  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "仕訳が見つかりません"
    redirect_to journal_entries_path
  end

  private

  def journal_entry_params
    params.require(:journal_entry).permit(:credit_title, :debit_title, :amount)
  end

  def set_user
    @user = User.find_by(email: session[:userinfo]["email"])
  end
end
