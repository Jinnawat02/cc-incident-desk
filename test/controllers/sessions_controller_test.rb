require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:customer) }

  test "new" do
    get new_session_path

    assert_response :success
    assert_select "h1", "Sign in"
    assert_select "input[type=email][name=email_address]"
    assert_select "input[type=password][name=password]"
    assert_select ".alert-error", count: 0
    assert_select "header", count: 0
  end

  test "new redirects a signed-in user to the dashboard" do
    sign_in_as @user

    get new_session_path

    assert_redirected_to root_path
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with valid credentials ignores email case" do
    post session_path, params: { email_address: "CUSTOMER@Example.com", password: "password" }

    assert_redirected_to root_path
  end

  test "create returns to the page that required sign-in" do
    get root_path
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_url
  end

  test "create with invalid credentials re-shows the form with the typed email" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
    assert_select ".alert-error[role=alert]", "Invalid email or password"
    assert_select "input[name=email_address][value=?]", @user.email_address
  end

  test "create with an unknown email shows the same error" do
    post session_path, params: { email_address: "nobody@example.com", password: "password" }

    assert_response :unprocessable_entity
    assert_select ".alert-error", "Invalid email or password"
  end

  test "destroy" do
    sign_in_as @user

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "after log out, protected pages redirect to sign-in" do
    post session_path, params: { email_address: @user.email_address, password: "password" }
    delete session_path

    get root_path

    assert_redirected_to new_session_path
  end
end
