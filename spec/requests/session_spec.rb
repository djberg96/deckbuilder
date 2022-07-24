require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  example "should get new" do
    get sessions_new_url
    assert_response :success
  end

  example "should get create" do
    get sessions_create_url
    assert_response :success
  end

  example "should get destroy" do
    get sessions_destroy_url
    assert_response :success
  end
end
