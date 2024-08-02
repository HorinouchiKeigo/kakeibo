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
      render json: {
        toast: render_toast("仕訳を保存しました", "notice"),
        table: render_table,
      }, status: :created
    else
      render json: {
        toast: render_toast("仕訳の保存に失敗しました", "alert"),
        table: render_table,
      }, status: :unprocessable_entity
    end
  end

  def destroy
    set_user
    @journal_entry = @user.journal_entries.find(params[:id])
    @journal_entry.destroy
    render json: {
      toast: render_toast("仕訳を削除しました", "notice"),
      table: render_table,
    }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: {
      toast: render_toast("仕訳が見つかりません", "alert"),
      table: render_table,
     }, status: :not_found
  end

  private

  def journal_entry_params
    params.require(:journal_entry).permit(:credit_title, :debit_title, :amount)
  end

  def set_user
    @user = User.find_by(email: session[:userinfo]["email"])
  end

  def render_table
    journal_entries = @user.journal_entries.order(created_at: :desc)
    render_to_string(partial: "journal_entries/table", locals: { journal_entries: journal_entries }, formats: [:html], layout: false)
  end

  def render_toast(message, type)
    render_to_string(partial: "journal_entries/toast", locals: { message: message, type: type }, formats: [:html], layout: false)
  end
end
