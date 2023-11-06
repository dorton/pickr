class MatchupsController < ApplicationController
  before_action :set_matchup, only: %i[ show edit update destroy ]

  # GET /matchups
  def index
    @matchups = Matchup.all
  end

  # GET /matchups/1
  def show
  end

  # GET /matchups/new
  def new
    @matchup = Matchup.new
  end

  # GET /matchups/1/edit
  def edit
  end

  # POST /matchups
  def create
    @matchup = Matchup.new(matchup_params)

    if @matchup.save
      redirect_to @matchup, notice: "Matchup was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /matchups/1
  def update
    if @matchup.update(matchup_params)
      redirect_to @matchup, notice: "Matchup was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /matchups/1
  def destroy
    @matchup.destroy!
    redirect_to matchups_url, notice: "Matchup was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_matchup
      @matchup = Matchup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def matchup_params
      params.require(:matchup).permit(:remote_id, :sport_key, :sport_title, :commence_time, :completed, :home_team, :away_team, :remote_last_updated, :scores)
    end
end
