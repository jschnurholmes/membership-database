require 'test_helper'

class Api::V1::MembershipsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get save" do
    get :save
    assert_response :success
  end

end
