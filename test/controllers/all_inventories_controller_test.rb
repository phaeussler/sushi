require 'test_helper'

class AllInventoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @all_inventory = all_inventories(:one)
  end

  test "should get index" do
    get all_inventories_url
    assert_response :success
  end

  test "should get new" do
    get new_all_inventory_url
    assert_response :success
  end

  test "should create all_inventory" do
    assert_difference('AllInventory.count') do
      post all_inventories_url, params: { all_inventory: {  } }
    end

    assert_redirected_to all_inventory_url(AllInventory.last)
  end

  test "should show all_inventory" do
    get all_inventory_url(@all_inventory)
    assert_response :success
  end

  test "should get edit" do
    get edit_all_inventory_url(@all_inventory)
    assert_response :success
  end

  test "should update all_inventory" do
    patch all_inventory_url(@all_inventory), params: { all_inventory: {  } }
    assert_redirected_to all_inventory_url(@all_inventory)
  end

  test "should destroy all_inventory" do
    assert_difference('AllInventory.count', -1) do
      delete all_inventory_url(@all_inventory)
    end

    assert_redirected_to all_inventories_url
  end
end
