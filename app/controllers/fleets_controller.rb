class FleetsController < ApplicationController
  def index
    @fleets = Fleet.all
  end

  def create
    @fleet = Fleet.new(params[:fleet])
    @fleet.reg_exp = "#{@fleet.keyword}(?:\s*)((\d|[.])+)(?:\s*)"
    @fleet.name = @fleet.keyword

    @fleet.save

    redirect_to :back
  end

  def destroy
    @fleet = Fleet.find(params[:id])
    @fleet.destroy

    respond_to do |format|
      format.html { redirect_to fleets_url }
      format.json { head :no_content }
    end
  end
end
