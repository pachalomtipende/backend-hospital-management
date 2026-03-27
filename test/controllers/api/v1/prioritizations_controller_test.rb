require "test_helper"

class Api::V1::PrioritizationsControllerTest < ActionDispatch::IntegrationTest
  test "should return bad request if symptoms are missing" do
    post api_v1_prioritize_url, params: {}
    assert_response :bad_request
    assert_equal "Please provide an array of symptoms", JSON.parse(response.body)["error"]
  end

  test "should return priority analysis for valid symptoms array" do
    post api_v1_prioritize_url, params: { symptoms: ["fever", "cough"] }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "MEDIUM", data["priority_level"]
    assert_equal 55, data["priority_score"]
  end
end
