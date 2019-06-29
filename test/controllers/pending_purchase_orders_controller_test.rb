require 'test_helper'

class PendingPurchaseOrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get pending_purchase_orders_create_url
    assert_response :success
  end

end
