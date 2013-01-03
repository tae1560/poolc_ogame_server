class DefensesController < ApplicationController
  def index
    @defenses = Defense.all
  end

  def create
    @defense = Defense.new(params[:defense])
    @defense.reg_exp = "#{@defense.keyword}(?:\s*)((\d|[.])+)(?:\s*)"
    @defense.name = @defense.keyword

    @defense.save

    redirect_to :back
  end

  def destroy
    @defense = Defense.find(params[:id])
    @defense.destroy

    respond_to do |format|
      format.html { redirect_to defenses_url }
      format.json { head :no_content }
    end
  end
end
