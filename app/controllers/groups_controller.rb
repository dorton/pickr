class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show update destroy ]

  # GET /groups
  def index
    @groups = Group.all

    render json: @groups
  end

  # GET /groups/1
  def show
    render json: @group
  end

  # POST /groups
  def create
    @user = User.find(params[:user][:id])
    @group = Group.new(group_params)

    if @group.save
      @group.users << @user
      @group.managers << @user
      if @user.group_defaults.empty?
        @group.defaults << @user
      end
      
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if params[:group][:toggle_default]
      current_user.group_defaults.delete_all
      if @group.defaults << current_user
        render json: @group
      else
        render json: @group.errors, status: :unprocessable_entity
      end
      return
    end
    
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name, :user_id, :slug, :is_private, :league, :sport, :regular_season, :post_season, :max_picks, :spread, :over_under)
    end
end
