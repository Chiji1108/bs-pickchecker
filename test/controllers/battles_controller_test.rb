require 'test_helper'

class BattlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get batlles_index_url
    assert_response :success
  end

end
