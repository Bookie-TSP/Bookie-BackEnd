require 'test_helper'

class ChaosControllerTest < ActionController::TestCase
  setup do
    @chao = chaos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:chaos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create chao" do
    assert_difference('Chao.count') do
      post :create, chao: {  }
    end

    assert_redirected_to chao_path(assigns(:chao))
  end

  test "should show chao" do
    get :show, id: @chao
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @chao
    assert_response :success
  end

  test "should update chao" do
    patch :update, id: @chao, chao: {  }
    assert_redirected_to chao_path(assigns(:chao))
  end

  test "should destroy chao" do
    assert_difference('Chao.count', -1) do
      delete :destroy, id: @chao
    end

    assert_redirected_to chaos_path
  end
end
