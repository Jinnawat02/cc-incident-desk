require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:customer) }

  test "shows the sign-in form" do
    get new_session_path

    assert_response :success
    assert_select "h1", "Sign in"
    assert_select "input[type=email][name=email_address]"
    assert_select "input[type=password][name=password]"
    assert_select "[role=alert]", count: 0
    assert_select "header", count: 0
  end

  test "correct credentials redirect to the ticket dashboard" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "wrong password re-shows the form with an error and keeps the email" do
    post session_path, params: { email_address: "Customer@Example.com", password: "wrong" }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", "Invalid email or password"
    assert_select "input[name=email_address][value=?]", "Customer@Example.com"
    assert_nil cookies[:session_id]
  end

  test "unknown email re-shows the form with an error" do
    post session_path, params: { email_address: "nobody@example.com", password: "password" }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", "Invalid email or password"
    assert_nil cookies[:session_id]
  end

  test "log out ends the session and returns to sign-in" do
    sign_in_as @user

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]

    get root_path
    assert_redirected_to new_session_path
  end

  test "log out redirects a visitor who isn't signed in to sign-in" do
    delete session_path

    assert_redirected_to new_session_path
  end

  test "sends a signed-in user from the sign-in page to the dashboard" do
    sign_in_as @user

    get new_session_path

    assert_redirected_to root_path
  end
end
