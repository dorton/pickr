class GroupManagersController < ApplicationController
  before_action :set_group
  before_action :set_user
  before_action :authorize_group_manager!

  def create
    unless @group.managers.include?(@user)
      @group.managers << @user
      render json: { status: :success, message: 'User added as a manager.' }, status: :created
    else
      render json: { status: :unprocessable_entity, message: 'User is already a manager.' }, status: :unprocessable_entity
    end
  end

  def destroy
    if @group.managers.include?(@user)
      @group.managers.delete(@user)
      render json: { status: :success, message: 'User removed from managers.' }, status: :ok
    else
      render json: { status: :unprocessable_entity, message: 'User is not a manager.' }, status: :unprocessable_entity
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
    @user = User.find(params[:id])
    unless @user
      render json: { status: :not_found, message: 'User not found.' }, status: :not_found
    end
  end

  def authorize_group_manager!
    unless @group.managers.include?(current_user)
      render json: { status: :forbidden, message: 'You are not authorized to perform this action.' }, status: :forbidden
    end
  end
end
