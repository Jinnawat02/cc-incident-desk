require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @customer = users(:customer) }

  test "new renders the sign in form" do
    get new_session_path

    assert_response :success
    assert_select "form[action=?]", session_path
    assert_select "input[name=email_address]"
    assert_select "input[name=password]"
    assert_select "[role=alert]", count: 0
  end

  test "new redirects a signed in user to the dashboard" do
    sign_in_as @customer

    get new_session_path

    assert_redirected_to root_path
  end

  test "create with valid customer credentials redirects to the dashboard" do
    post session_path, params: { email_address: @customer.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with valid agent credentials redirects to the dashboard" do
    post session_path, params: { email_address: users(:agent).email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create returns to the originally requested page" do
    get dashboard_path
    post session_path, params: { email_address: @customer.email_address, password: "password" }

    assert_redirected_to dashboard_url
  end

  test "create with a wrong password shows an error" do
    post session_path, params: { email_address: @customer.email_address, password: "wrong" }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", "Invalid email or password"
    assert_nil cookies[:session_id]
  end

  test "create with an unknown email shows an error" do
    post session_path, params: { email_address: "nobody@example.com", password: "password" }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", "Invalid email or password"
    assert_nil cookies[:session_id]
  end

  test "create with blank credentials shows an error" do
    post session_path, params: { email_address: "", password: "" }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", "Invalid email or password"
  end

  test "destroy signs the user out" do
    sign_in_as @customer

    assert_difference -> { @customer.sessions.count }, -1 do
      delete session_path
    end

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "destroy requires authentication" do
    delete session_path

    assert_redirected_to new_session_path
  end
end
