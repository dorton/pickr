require "test_helper"

class PicksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pick = picks(:one)
  end

  test "should get index" do
    get picks_url, as: :json
    assert_response :success
  end

  test "should create pick" do
    assert_difference("Pick.count") do
      post picks_url, params: { pick: { confidence: @pick.confidence, game_id: @pick.game_id, team_id: @pick.team_id, week: @pick.week } }, as: :json
    end

    assert_response :created
  end

  test "should show pick" do
    get pick_url(@pick), as: :json
    assert_response :success
  end

  test "should update pick" do
    patch pick_url(@pick), params: { pick: { confidence: @pick.confidence, game_id: @pick.game_id, team_id: @pick.team_id, week: @pick.week } }, as: :json
    assert_response :success
  end

  test "should destroy pick" do
    assert_difference("Pick.count", -1) do
      delete pick_url(@pick), as: :json
    end

    assert_response :no_content
  end
end
