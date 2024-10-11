class HomeController < ApplicationController
    before_action :set_group
    before_action :set_week_value
    before_action :set_user
    before_action :authorize_group_access!, only: [:index, :show, :group]
    before_action :authorize_group_manager!, only: [:add_user_as_admin, :remove_user_as_admin, :remove_user]
  
    def index
      @current_week = current_week.first
      @matchups = helpers.espnScores(@week_value, @group.sport, @group.league)
      @week_calendar = get_calendar_by_week_value(@week_value)
      @saved_picks = @group.picks.where(week: @week_value)
      @saved_games = @group.games.where(week: @week_value)
      @all_games = get_all_games(@week_calendar)
  
      game_check_or_update
  
      render inertia: "groups/index", props: {
        matchups: @matchups,
        current_week: @current_week.value,
        user: @user,
        setting: @user.setting,
        users: @group.users,
        week: @week_value,
        week_calendar: @week_calendar,
        saved_picks: @saved_picks,
        saved_games: @saved_games,
        all_games: @all_games,
        all_picks: @group.picks.where(game_id: @all_games.pluck(:id)),
        current_group: @group.as_json(include: [:managers, :users, :defaults]),
        user_groups: @user.groups.as_json(include: [:managers, :users, :defaults]),
        current_calendar: @current_week,
        calendars: get_all_calendars
      }
    end
  
    def manage_groups
      @matchups = @group ? helpers.espnScores(@week_value, @group.sport, @group.league) : nil
      @saved_games = @group ? @group.games.where(week: @week_value) : []
  
      render inertia: "users/index", props: {
        user: @user.as_json(include: [:groups, :group_defaults]),
        user_groups: @user.groups,
        week: @week_value,
        groups: Group.where(is_private: false),
        calendars: get_all_calendars,
        matchups: @matchups,
        current_calendar: current_week.first,
        week_calendar: get_calendar_by_week_value(@week_value),
        saved_games: @saved_games,
        managed_groups_with_users: @user.groups.includes(:users).as_json(include: [:users, :managers, :defaults])
      }
    end
  
    def add_user_as_admin
      target_user = User.find_by(id: params[:user][:id])
      if target_user && @group
        @group.managers << target_user unless @group.managers.include?(target_user)
        render json: { status: :success }
      else
        render json: { status: :unprocessable_entity, message: 'Group or user not found.' }
      end
    end
  
    def remove_user_as_admin
      target_user = User.find_by(id: params[:user][:id])
      if target_user && @group
        @group.managers.delete(target_user)
        render json: { status: :success }
      else
        render json: { status: :unprocessable_entity, message: 'Group or user not found.' }
      end
    end
  
    def adduser
      if @user && @group
        @group.defaults << @user if @user.group_defaults.empty?
        @group.users << @user unless @group.users.include?(@user)
        render json: { status: :success }
      else
        render json: { status: :unprocessable_entity, message: 'Group not found. Please check the code with the group manager.' }
      end
    end
  
    def remove_user
      target_user = User.find_by(id: params[:user_id])
      if target_user && @group
        target_user.group_defaults.delete(@group) if target_user.group_defaults.include?(@group)
        @group.users.delete(target_user)
        target_user.group_defaults << target_user.groups.first if target_user.groups.any?
        render json: { status: :success }
      else
        render json: { status: :unprocessable_entity, message: 'Could not remove user from the group.' }
      end
    end
  
    def group
      if @group && @user.groups.include?(@group)
        redirect_to groupweekhome_path(group_slug: @group.slug, week_id: @week_value)
      else
        redirect_to root_url, alert: 'You are not a member of this group.'
      end
    end
  
    def show
      @matchups = helpers.espnScores(@week_value, @group.sport, @group.league)
      @week_calendar = get_calendar_by_week_value(@week_value)
      @saved_games = @group.games.where(week: @week_value)
  
      game_check_or_update
  
      render inertia: "matchups/index", props: {
        matchups: @matchups,
        current_week: current_week.first.value,
        user: @user,
        users: @group.users,
        week: @week_value,
        week_calendar: @week_calendar,
        saved_picks: @group.picks.where(week: @week_value, user_id: @user.id),
        saved_games: @saved_games,
        current_group: @group.as_json(include: :managers),
        user_groups: @user.groups,
        current_calendar: current_week.first,
        calendars: get_all_calendars
      }
    end
  
    private
  
    def set_group
      @group = if params[:group_slug]
                 Group.includes(:games, :picks, :users).find_by(slug: params[:group_slug])
               else
                 current_user.group_defaults.includes(:games, :picks, :users).first
               end
      @group ||= current_user.group_defaults.first
    end
  
    def set_week_value
      @week_value = params[:week_id] || current_week.first.value
    end
  
    def set_user
      @user = current_user
    end
  
    def authorize_group_access!
      unless @group && @user.groups.include?(@group)
        redirect_to manage_groups_path, alert: 'You do not have access to this group.'
      end
    end
  
    def authorize_group_manager!
      unless @group.managers.include?(@user)
        redirect_to root_path, alert: 'You are not authorized to perform this action.'
      end
    end
  
    def get_all_games(calendar)
      return [] unless @group && calendar
  
      @group.games.where(calendar_id: get_cal_for_group(calendar).pluck(:id))
    end
  
    def get_cal_for_group(calendar)
      Calendar.where(league: @group.league).where('startDate <= ?', calendar.startDate)
    end
  
    def game_check_or_update
      saved_games = @group.games.where(week: @week_value)
      mapped_saved_game_ids = saved_games.pluck(:remote_game_id).map(&:to_s)
      all_non_pre_events = @matchups['events'].reject { |e| e['status']['type']['state'] == 'pre' }
      in_progress_games = all_non_pre_events.select { |event| mapped_saved_game_ids.include?(event['id']) }
  
      in_progress_games.each do |event|
        saved_game = saved_games.find { |g| g.remote_game_id == event['id'].to_i }
        if saved_game && !saved_game.completed
          helpers.update_game(saved_game, @matchups['events'])
        else
          winner_check
        end
      end
    end
  
    def winner_check
      helpers.handle_winning_picks(@week_value, @group.league, @group.sport, @matchups)
    end
  
    def get_all_calendars
      Calendar.where(sport: @group.sport, league: @group.league)
    end
  
    def get_calendar_by_week_value(week_value)
      get_all_calendars.find_by(value: week_value)
    end
  
    def current_week
      get_all_calendars.where('? BETWEEN startDate AND endDate', Time.current)
    end
end
  