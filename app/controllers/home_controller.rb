class HomeController < ApplicationController
  before_action :set_user
  before_action :set_group
  before_action :set_year
  before_action :set_current_week
  before_action :set_all_calendars
  before_action :set_week_value

  def index
    return redirect_to manage_groups_path, alert: 'No group found.' unless @group

    @matchups = set_matchups(@week_value, @group.sport, @group.league)
    logger.info(@matchups)
    @week_calendar = get_calendar_by_week_value(@week_value)
    @saved_picks = @group.picks.joins(:game).joins('JOIN calendars ON games.calendar_id = calendars.id').where('calendars.year = ? AND games.week = ?', @year, @week_value)
    @saved_games = @group.games.joins(:calendar).where('calendars.year = ? AND games.week = ?', @year, @week_value)
    @all_games = get_all_games(@week_calendar)

    game_check_or_update

    render inertia: 'groups/index', props: {
      matchups: @matchups,
      current_week: @current_week&.value,
      user: @user,
      setting: @user&.setting,
      users: @group.users,
      week: @week_value,
      year: @year,
      week_calendar: @week_calendar,
      saved_picks: @saved_picks,
      saved_games: @saved_games,
      all_games: @all_games,
      all_picks: @group.picks.joins(:game).joins('JOIN calendars ON games.calendar_id = calendars.id').where('calendars.year = ? AND games.id IN (?)', @year, @all_games.pluck(:id)),
      current_group: @group.as_json(include: %i[managers users defaults]),
      user_groups: @user&.groups&.as_json(include: %i[managers users defaults]) || [],
      current_calendar: @current_week,
      calendars: @calendars,
      is_manager: @group.managers.include?(current_user)
    }
  end

  def manage_groups
    @matchups = @group ? set_matchups(@week_value, @group.sport, @group.league) : nil
    @saved_games = @group ? @group.games.joins(:calendar).where('calendars.year = ? AND games.week = ?', @year, @week_value) : []

    render inertia: 'users/index', props: {
      user: @user.as_json(include: %i[groups group_defaults]),
      user_groups: @user.groups,
      week: @week_value,
      year: @year,
      groups: Group.where(is_private: false),
      calendars: @calendars,
      matchups: @matchups,
      current_calendar: @current_week,
      week_calendar: get_calendar_by_week_value(@week_value),
      saved_games: @saved_games,
      managed_groups_with_users: @user.groups.includes(:users).as_json(include: %i[users managers defaults])
    }
  end

  def group
    if @group && @user.groups.include?(@group)
      # Get the current year or default to current year if no year specified
      year = @year || Date.current.year
      redirect_to groupweekhome_path(group_slug: @group.slug, year: year, week_id: @week_value)
    else
      redirect_to root_url, alert: 'You are not a member of this group.'
    end
  end

  def show
    return redirect_to manage_groups_path, alert: 'No group found.' unless @group

    @matchups = set_matchups(@week_value, @group.sport, @group.league)
    @week_calendar = get_calendar_by_week_value(@week_value)
    @saved_games = @group.games.joins(:calendar).where('calendars.year = ? AND games.week = ?', @year, @week_value)

    game_check_or_update

    render inertia: 'matchups/index', props: {
      matchups: @matchups,
      current_week: @current_week&.value,
      user: @user,
      users: @group.users,
      week: @week_value,
      year: @year,
      week_calendar: @week_calendar,
      saved_picks: @group.picks.joins(:game).joins('JOIN calendars ON games.calendar_id = calendars.id').where('calendars.year = ? AND games.week = ? AND picks.user_id = ?', @year, @week_value, @user.id),
      saved_games: @saved_games,
      current_group: @group.as_json(include: :managers),
      user_groups: @user&.groups || [],
      current_calendar: @current_week,
      calendars: @calendars,
      is_manager: @group.managers.include?(current_user)
    }
  end

  def adminedit
    return redirect_to manage_groups_path, alert: 'No group found.' unless @group

    @matchups = set_matchups(@week_value, @group.sport, @group.league)
    @week_calendar = get_calendar_by_week_value(@week_value)
    @saved_games = @group.games.joins(:calendar).where('calendars.year = ? AND games.week = ?', @year, @week_value)
    user = User.find(params[:user_id])
    game_check_or_update

    render inertia: 'matchups/index', props: {
      matchups: @matchups,
      current_week: @current_week&.value,
      user:,
      users: @group.users,
      week: @week_value,
      year: @year,
      week_calendar: @week_calendar,
      saved_picks: @group.picks.joins(:game).joins('JOIN calendars ON games.calendar_id = calendars.id').where('calendars.year = ? AND games.week = ? AND picks.user_id = ?', @year, @week_value, user.id),
      saved_games: @saved_games,
      current_group: @group.as_json(include: :managers),
      user_groups: user&.groups || [],
      current_calendar: @current_week,
      calendars: @calendars,
      is_manager: @group.managers.include?(current_user)
    }
  end

  private

  def set_matchups(week_value, sport, league)
    EspnScores.call(week_value, sport, league)
  end

  def set_group
    @group = if params[:group_slug]
               Group.includes(:games, :picks, :users).find_by(slug: params[:group_slug])
             else
               current_user.group_defaults.includes(:games, :picks, :users).first
             end
    @group ||= current_user.group_defaults.first
  end

  def set_year
    @year = params[:year]&.to_i || Date.current.year
  end

  def set_week_value
    @week_value = params[:week_id] || @current_week&.value
  end

  def set_user
    @user = current_user
  end

  def authorize_group_access!
    return if @group && @user.groups.include?(@group)

    redirect_to manage_groups_path, alert: 'You do not have access to this group.'
  end

  def authorize_group_manager!
    return if @group.managers.include?(@user)

    redirect_to root_path, alert: 'You are not authorized to perform this action.'
  end

  def get_all_games(calendar)
    return [] unless @group && calendar

    cal_ids = get_cal_for_group(calendar).select(:id)
    @group.games.where(calendar_id: cal_ids)
  end

  def get_cal_for_group(calendar)
    Calendar.where(league: @group.league, year: @year).where('startDate <= ?', calendar.startDate)
  end

  def game_check_or_update
    return unless @matchups && @matchups['events']

    saved_games = @group.games.joins(:calendar).where('calendars.year = ? AND games.week = ?', @year, @week_value)
    mapped_saved_game_ids = saved_games.pluck(:remote_game_id).map(&:to_s)
    all_non_pre_events = @matchups['events'].reject { |e| e['status']['type']['state'] == 'pre' }
    in_progress_games = all_non_pre_events.select { |event| mapped_saved_game_ids.include?(event['id']) }

    in_progress_games.each do |event|
      saved_game = saved_games.find { |g| g.remote_game_id == event['id'].to_i }
      if saved_game && !saved_game.completed
        UpdateGame.call(saved_game, @matchups['events'])
      else
        WinnerChecker.call(@week_value, @group.league, @group.sport, @matchups)
      end
    end
  end

  def get_calendar_by_week_value(week_value)
    Calendar.get_calendar_by_week_value(week_value, @group, @year)
  end

  def set_all_calendars
    @calendars = Calendar.get_all_calendars(@group, @year)
  end

  def set_current_week
    @current_week = Calendar.current_week(@group, nil, @year)
  end
end
