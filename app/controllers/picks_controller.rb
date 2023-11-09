class PicksController < ApplicationController
  before_action :set_pick, only: %i[ show update destroy ]

  # GET /picks
  def index
    @picks = Pick.all

    render json: @picks
  end

  # GET /picks/1
  def show
    render json: @pick
  end

  # POST /picks
  def create
    @picks = Pick.upsert_all(params[:pick])
    @group = Group.find(params[:group][:id])

    if @picks
      arr =  @picks.rows.map{|r| r.first}
      @picks.rows.each do |row|
        row.each do |id|
          pick = Pick.find(id)
          group_picks = @group.picks
          group_picks << pick unless group_picks.include? pick
        end
      end
      render json: {status: :created}
    else
      render json: @picks.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /picks/1
  def update
    if @pick.update(pick_params)
      render json: @pick
    else
      render json: @pick.errors, status: :unprocessable_entity
    end
  end

  # DELETE /picks/1
  def destroy
    @pick.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pick
      @pick = Pick.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def pick_params
      # params.require(:pick).permit(:week, :game_id, :confidence, :team_id)
      # params.require(:pick).permit([])
    end
end
