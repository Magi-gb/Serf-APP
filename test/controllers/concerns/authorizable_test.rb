require "test_helper"

# Test controllers to exercise each authorization guard in isolation.
class AdminOnlyController < ApplicationController
  before_action :require_admin!

  def index
    head :ok
  end
end

class KitchenManagerOrAboveController < ApplicationController
  before_action :require_kitchen_manager_or_above!

  def index
    head :ok
  end
end

class AuthorizableTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    Rails.application.routes.draw do
      devise_for :users, skip: [ :registrations, :passwords ]
      get "admin_only", to: "admin_only#index"
      get "kitchen_manager_or_above", to: "kitchen_manager_or_above#index"
      root "home#index"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "require_admin! allows admin" do
    sign_in users(:admin)
    get "/admin_only"
    assert_response :success
  end

  test "require_admin! rejects kitchen_manager" do
    sign_in users(:kitchen_manager)
    get "/admin_only"
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "require_admin! rejects waiter" do
    sign_in users(:waiter)
    get "/admin_only"
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "require_kitchen_manager_or_above! allows admin" do
    sign_in users(:admin)
    get "/kitchen_manager_or_above"
    assert_response :success
  end

  test "require_kitchen_manager_or_above! allows kitchen_manager" do
    sign_in users(:kitchen_manager)
    get "/kitchen_manager_or_above"
    assert_response :success
  end

  test "require_kitchen_manager_or_above! rejects waiter" do
    sign_in users(:waiter)
    get "/kitchen_manager_or_above"
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end
end
