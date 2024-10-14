class GroupUsersController < ApplicationController
  before_action :set_group
  before_action :set_user, only: [:destroy]
  # before_action :authorize_group_access!
  before_action :authorize_group_manager!, only: [:destroy]

  def create
    if @group.is_private
      render json: { status: :forbidden, message: 'Cannot join a private group without an invitation.' }, status: :forbidden
    else
      unless @group.users.include?(current_user)
        @group.users << current_user
        current_user.group_defaults << @group if current_user.group_defaults.empty?
      end
      render json: { status: :success, message: 'Joined the group successfully.' }, status: :created
    end
  end

  def destroy
    # Only a group manager or the user themselves can remove a user
    if @user == current_user || @group.managers.include?(current_user)
      @group.users.destroy(@user)
      # Handle default group if necessary
      if @user.group_defaults.include?(@group)
        @user.group_defaults.delete(@group)
        @user.group_defaults << @user.groups.first if @user.groups.any?
      end
      render json: { status: :success, message: 'User removed from the group.' }, status: :ok
    else
      render json: { status: :forbidden, message: 'You are not authorized to perform this action.' }, status: :forbidden
    end
  end

  private

  def set_group
    @group = Group.find_by(slug: params[:group_slug])
    unless @group
      render json: { status: :not_found, message: 'Group not found.' }, status: :not_found
    end
  end

  def set_user
    @user = User.find_by(id: params[:id])
    unless @user
      render json: { status: :not_found, message: 'User not found.' }, status: :not_found
    end
  end

  # def authorize_group_access!
  #   unless @group.users.include?(current_user)
  #     render json: { status: :forbidden, message: 'You are not authorized to perform this action.' }, status: :forbidden
  #   end
  # end

  def authorize_group_manager!
    unless @group.managers.include?(current_user)
      render json: { status: :forbidden, message: 'You are not authorized to perform this action.' }, status: :forbidden
    end
  end
end
