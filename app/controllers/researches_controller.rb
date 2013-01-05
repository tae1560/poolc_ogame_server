class ResearchesController < ApplicationController
  def index
    @researches = Research.all
  end

  def create
    @research = Research.new(params[:research])
    @research.reg_exp = "#{@research.keyword}(?:\s*)((\d|[.])+)(?:\s*)"
    @research.name = @research.keyword

    @research.save

    redirect_to :back
  end

  def destroy
    @research = Research.find(params[:id])
    @research.destroy

    respond_to do |format|
      format.html { redirect_to researches_url }
      format.json { head :no_content }
    end
  end
end
