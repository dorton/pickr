class HomeController < ApplicationController
  
    def index
        @group = params[:group_slug] ? Group.includes(:games, :picks, :users).find_by_slug(params[:group_slug]) : current_user.groups.includes(:games, :picks, :users).first
        if !@group
            @group = Group.where(is_private: false).first
        end
        
        @current_week = current_week(@group).first
        @week_value = params[:week_id] || @current_week.value
        @matchups = helpers.espnScores(@week_value, @group.sport, @group.league)
        @week_calendar = @group ? get_calendar_by_week_value(@group, @week_value) : nil
        @group_sport = @group ? @group.sport : nil
        @group_league = @group ? @group.league : nil
        @user = current_user
        @saved_picks = @group.picks.where(week: @week_value)
        @saved_games = @group.games.where(week: @week_value)
        @all_games = get_all_games(@group, @week_calendar)
        if @group && @user.groups.include?(@group)
            game_check_or_update(@matchups, @saved_games, @week_value, @group_league, @group_sport)
            render inertia: "groups/index", props: {
              matchups: @matchups,
              current_week: @current_week.value,
              user: @user,
              users: @group.users,
              week: @week_value,
              week_calendar: @week_calendar,
              saved_picks: @saved_picks,
              saved_games: @saved_games,
              all_games: @all_games,
              all_picks: @group.picks.where(game_id: @all_games.pluck(:id)),
              current_group: @group,
              user_groups: current_user.groups,
              current_calendar: @current_week,
              calendars: @group ? get_all_calendars(@group) : nil
            }
        
        elsif !@group ||(@group && current_user.groups.empty?)
                redirect_to manage_groups_path
        else 
            redirect_to manage_groups_path
        end
        
    end

    def manage_groups
        @group = current_user.groups.first
        if !@group
            @group = Group.where(is_private: false).first
        end
        @week_value = params[:week_id] || current_week(@group).first.value
        @week_calendar = @group ? get_calendar_by_week_value(@group, @week_value) : nil
        @group_sport = @group ? @group.sport : nil
        @group_league = @group ? @group.league : nil
        @matchups = @group ? helpers.espnScores(@week_value, @group.sport, @group.league) : nil
        @user = current_user
        @saved_games = @group ? @group.games.where(week: @week_value) : []
        render inertia: "users/index", props: {
            user: User.includes(:groups).find(@user.id).as_json({groups: :groups}),
            user_groups: @user.groups,
            week: @week_value,
            groups: Group.all.where(is_private: false),
            calendars: @group ? get_all_calendars(@group) : nil,
            matchups: @matchups,
            current_calendar: current_week(@group).first,
            week_calendar: @week_calendar,
            saved_games: @saved_games,
        } 
    end
    

    def adduser
        @user = current_user
        if !params[:group_id].nil?
            @group = Group.find(params[:group_id])
        elsif !params[:group_slug].nil?
            @group = Group.find_by_slug(params[:group_slug])
        end
        if @user && @group
            @group.users << @user if !@group.users.include?(@user)
            render json: {status: :success}
        else 
            render json: {status: :unprocessable_entity, message: 'Sorry, Could Not Find Group. Reach Out To The Group Manager And Make Sure You Have The Correct Code'}
        end
    end

    def remove_user 
        @user = User.find(params[:user_id])
        if !params[:group_id].nil?
            @group = Group.find(params[:group_id])
        elsif !params[:group_slug].nil?
            @group = Group.find_by_slug(params[:group_slug])
        end
        if @user && @group
            @group.users.delete(@user)
            render json: {status: :success}
        else 
            render json: {status: :unprocessable_entity, message: 'Sorry, Could Not Remove From Group. I Dunno.'}
        end
    end

    def group
        @group = params[:group_slug] ? Group.find_by_slug(params[:group_slug]) : current_user.groups.first
        if !@group
            @group = Group.where(is_private: false).first
        end
        @week = params[:week_id] || current_week(@group).first.value
        @group_sport = @group ? @group.sport : nil
        @group_league = @group ? @group.league : nil
        @matchups = helpers.espnScores(@week, @group.sport, @group.league)
        @user = current_user
        if !@group || (@group && !@user.groups.include?(@group))
            redirect_to root_url 
        else 
            redirect_to groupweekhome_path(group_slug: @group.slug, week_id: @week)
        end
    end
    
    def show
        @group = Group.find_by_slug(params[:group_slug])
        if !@group
            @group = Group.where(is_private: false).first
        end
        @week_value = params[:week_id]
        @week_calendar = @group ? get_calendar_by_week_value(@group, @week_value) : nil
        @matchups = helpers.espnScores(@week_value, @group.sport, @group.league)
        @user = params[:user_id] ? User.find(params[:user_id]) : current_user
        @saved_games = @group.games.where(week: @week_value)
        if @group && @user.groups.include?(@group)
            game_check_or_update(@matchups, @saved_games, @week_value, @group.league, @group.sport)
            render inertia: "matchups/index", props: {
                matchups: @matchups,
                current_week: current_week(@group).first.value,
                user: @user,
                users: @group.users,
                week: @week_value,
                week_calendar: @week_calendar,
                saved_picks: @group.picks.where(week: @week_value).where(user_id: current_user.id),
                saved_games: @saved_games,
                current_group: @group,
                user_groups: current_user.groups,
                current_calendar: current_week(@group).first,
                calendars: @group ? get_all_calendars(@group) : nil
            }    
        else
            redirect_to manage_groups_path
        end
    end

    def adminedit
        @group = Group.find_by_slug(params[:group_slug])
        if !@group
            @group = Group.where(is_private: false).first
        end
        @week = params[:week_id]
        @matchups = helpers.espnScores(@week, @group.sport, @group.league)
        @user = params[:user_id] ? User.find(params[:user_id]) : current_user
        if @group && @user.groups.include?(@group) && current_user.is_admin
            render inertia: "matchups/index", props: {
                matchups: @matchups,
                current_week: current_week(@group).first.value,
                user: @user,
                users: @group.users,
                week: @week,
                saved_picks: @group.picks.where(week: @week).where(user_id: @user.id),
                saved_games: @group.games.where(week: @week),
                current_group: @group,
                user_groups: @user.groups,
                current_calendar: current_week(@group).first,
                calendars: @group ? get_all_calendars(@group) : nil
            }    
        else
            redirect_to root_url
        end
    end

    private
    def get_all_games(group, calendar)
        group.games.where(calendar_id: get_cal_for_group(group, calendar).pluck(:id))
    end
    
    def get_cal_for_group(group, calendar)
        Calendar.where(league: group.league).where('startDate <= ?', calendar.startDate)
    end
    
    def game_check_or_update(matchups, saved_games, week_slug, league, sport='football')
        mapped_save_games = saved_games.map {|sg| sg.remote_game_id.to_s }
        all_non_pre_events = matchups['events'].select {|e| e['status']['type']['state'] != 'pre' }
        my_inprogress_games = all_non_pre_events.select {|rg_in_progress| mapped_save_games.include? rg_in_progress['id']}
        my_inprogress_games.each do |rg_ip|
            saved_game = saved_games.find {|g| g.remote_game_id == rg_ip['id'].to_i }
            if !saved_game.completed
                helpers.update_game(saved_game, matchups['events'])
            else
                winner_check(week_slug, league, sport, matchups)
            end 
        end
    end

    def winner_check(week_slug, league, sport, matchups)
        helpers.handle_winning_picks(week_slug, league, sport, matchups)
    end
    
    def get_all_calendars(group)
        sport = group.sport || 'football'
        league = group.league || 'college-football'
        Calendar.where(sport: group.sport)
                .where(league: group.league)
    end
    
    def get_calendar_by_week_value(group, week_value)
        get_all_calendars(group).find_by_value(week_value)
    end

    def current_week(group)
        get_all_calendars(group).where('? BETWEEN startDate AND endDate', Time.now)
    end
    
  end