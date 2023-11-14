class GamesController < ApplicationController
  before_action :set_game, only: %i[ show destroy ]

  # GET /games
  def index
    @games = Game.all

    render json: @games
  end

  # GET /games/1
  def show
    render json: @game
  end

  # POST /games
  def create
    @group = Group.find(params[:group][:id])
    @game = Game.new(game_params)

    if @game.save
      @group.games << @game
      render json: @game, status: :created, location: @game
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /games/1
  def update
    @game = Game.find(params[:id])
    if @game.update(game_params)
      render json: @game
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # DELETE /games/1
  def destroy
    @game.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find_by_remote_game_id(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def game_params
      params.require(:game).permit(:week, :remote_game_id, :set_odds, :favored_team_id, :odds, :home_team, :away_team, :home_score, :away_score, :home_team_id, :away_team_id, :completed)
    end
end
