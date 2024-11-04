# test/controllers/home_page_controller_test.rb
require "test_helper"

class Api::HomePageControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
  end

  def mock_authenticate_user(user)
    Api::HomePageController.any_instance.stubs(:authenticate_devise_api_token!).returns(true)
    Api::HomePageController.any_instance.stubs(:current_user).returns(user)
    yield
  end

  test "should get home page as admin" do
    mock_authenticate_user(@admin_user) do
      get api_home_page_path, headers: { "Content-Type": "application/json" }
      assert_response :success
      json_response = JSON.parse(response.body)
      assert json_response["tasks"].present?, "Expected tasks to be present in response"
    end
  end

  test "should get home page as manager" do
    mock_authenticate_user(@manager_user) do
      get api_home_page_path, headers: { "Content-Type": "application/json" }
      assert_response :success
      json_response = JSON.parse(response.body)
      assert json_response["tasks"].present?, "Expected tasks to be present in response"
    end
  end

  test "should get home page as agent" do
    mock_authenticate_user(@agent_user) do
      get api_home_page_path, headers: { "Content-Type": "application/json" }
      assert_response :success
      json_response = JSON.parse(response.body)
      assert json_response["tasks"].present?, "Expected tasks to be present in response"
    end
  end

  test "should return unauthorized for unauthenticated access" do
    get api_home_page_path, headers: { "Content-Type": "application/json" }
    assert_response :unauthorized
  end
end
