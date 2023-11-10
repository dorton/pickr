class HomeController < ApplicationController
  
    def index
        @group = params[:group_slug] ? Group.find_by_slug(params[:group_slug]) : current_user.groups.first
        @week = params[:week_id] ? params[:week_id].split('week_').last : current_week.first.value
        @matchups = helpers.espnScores(@week)
        @user = current_user
        render inertia: "groups/index", props: {
          matchups: @matchups,
          current_week: current_week.first.value,
          user: @user,
          users: @group.users,
          week: @week,
          saved_picks: @group.picks.where(week: @week),
          saved_games: @group.games.where(week: @week),
          current_group: @group,
          user_groups: current_user.groups,
          current_calendar: current_week.first,
          calendars: Calendar.all
        }
  
      
    end
    def show
        @group = Group.find_by_slug(params[:group_slug])
        @week = params[:week_id].split('week_').last
        @matchups = helpers.espnScores(@week)
        @user = current_user
        if @group
            render inertia: "matchups/index", props: {
                matchups: @matchups,
                current_week: current_week.first.value,
                user: @user,
                users: @group.users,
                week: @week,
                saved_picks: @group.picks.where(week: @week).where(user_id: current_user.id),
                saved_games: @group.games.where(week: @week),
                current_group: @group,
                user_groups: current_user.groups,
                current_calendar: current_week.first,
                calendars: Calendar.all
            }    
        else
            redirect_to root_url
        end
    end

    private
    def current_week
      Calendar.where('? BETWEEN startDate AND endDate', Date.today)
    end
    
  end