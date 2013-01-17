class AttacksController < ApplicationController
  before_filter :authenticate_user

  def destroy
    @attack = Attack.find(params[:id])
    @attack.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end
