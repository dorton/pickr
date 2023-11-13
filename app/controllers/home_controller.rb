class HomeController < ApplicationController
  
    def index
        @group = params[:group_slug] ? Group.find_by_slug(params[:group_slug]) : current_user.groups.first
        @week_value = params[:week_id] ? params[:week_id].split('week_').last : current_week.first.value
        @week_calendar = Calendar.find_by_value(@week_value)
        @matchups = helpers.espnScores(@week_value)
        @user = current_user
        if @group && @user.groups.include?(@group)
            render inertia: "groups/index", props: {
              matchups: @matchups,
              current_week: current_week.first.value,
              user: @user,
              users: @group.users,
              week: @week_value,
              week_calendar: @week_calendar,
              saved_picks: @group.picks.where(week: @week_value),
              saved_games: @group.games.where(week: @week_value),
              current_group: @group,
              user_groups: current_user.groups,
              current_calendar: current_week.first,
              calendars: Calendar.all
            }
        end
        if !@group ||(@group && current_user.groups.empty?)
                render inertia: "users/index", props: {
                    user: @user,
                    user_groups: @user.groups,
                    week: @week,
                    groups: Group.all.where(is_private: false),
                    calendars: Calendar.all,
                    matchups: @matchups,
                  } 
        end
        
    end

    def manage_groups
        @group = current_user.groups.first
        @week_value = params[:week_id] ? params[:week_id].split('week_').last : current_week.first.value
        @week_calendar = Calendar.find_by_value(@week_value)
        @matchups = helpers.espnScores(@week)
        @user = current_user
        if @group
            render inertia: "users/index", props: {
                user: User.includes(:groups).find(@user.id).as_json({groups: :groups}),
                user_groups: @user.groups,
                week: @week_value,
                groups: Group.all.where(is_private: false),
                calendars: Calendar.all,
                matchups: @matchups,
                current_calendar: current_week.first,
                week_calendar: @week_calendar,
              } 
        else
            redirect_to root_url
        end
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
        @week = params[:week_id] ? params[:week_id].split('week_').last : current_week.first.value
        @matchups = helpers.espnScores(@week)
        @user = current_user
        if !@group || (@group && !@user.groups.include?(@group))
            redirect_to root_url 
        else 
            redirect_to groupweekhome_path(group_slug: @group.slug, week_id: "week_#{@week}")
        end
    end
    
    def show
        @group = Group.find_by_slug(params[:group_slug])
        @week_value = params[:week_id].split('week_').last
        @week_calendar = Calendar.find_by_value(@week_value)
        @matchups = helpers.espnScores(@week_value)
        @user = params[:user_id] ? User.find(params[:user_id]) : current_user
        if @group && @user.groups.include?(@group)
            render inertia: "matchups/index", props: {
                matchups: @matchups,
                current_week: current_week.first.value,
                user: @user,
                users: @group.users,
                week: @week_value,
                week_calendar: @week_calendar,
                saved_picks: @group.picks.where(week: @week_value).where(user_id: current_user.id),
                saved_games: @group.games.where(week: @week_value),
                current_group: @group,
                user_groups: current_user.groups,
                current_calendar: current_week.first,
                calendars: Calendar.all
            }    
        else
            redirect_to root_url
        end
    end

    def adminedit
        @group = Group.find_by_slug(params[:group_slug])
        @week = params[:week_id].split('week_').last
        @matchups = helpers.espnScores(@week)
        @user = params[:user_id] ? User.find(params[:user_id]) : current_user
        if @group && @user.groups.include?(@group) && current_user.is_admin
            render inertia: "matchups/index", props: {
                matchups: @matchups,
                current_week: current_week.first.value,
                user: @user,
                users: @group.users,
                week: @week,
                saved_picks: @group.picks.where(week: @week).where(user_id: @user.id),
                saved_games: @group.games.where(week: @week),
                current_group: @group,
                user_groups: @user.groups,
                current_calendar: current_week.first,
                calendars: Calendar.all
            }    
        else
            redirect_to root_url
        end
    end

    private
    def current_week
      Calendar.where('? BETWEEN startDate AND endDate', Time.now)
    end
    
  end