# frozen_string_literal: true

class Api::GamesController < ApplicationController

  def index
    league = params[:league] || 'college-football'
    value = params[:week] || Calendar.current_week&.value
    year = params[:year] || Date.current.year
    @calendar = Calendar.where(league:).where(value:).where(year:).first
    
    if @calendar
      @games = @calendar.games
        .joins("LEFT JOIN matchups ON games.remote_game_id = matchups.remote_id")
        .select("games.*, matchups.*")
    else
      @games = []
    end

    render json: @games
  end

end
