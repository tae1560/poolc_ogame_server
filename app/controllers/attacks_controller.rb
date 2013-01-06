class AttacksController < ApplicationController
  def destroy
    @attack = Attack.find(params[:id])
    @attack.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end
