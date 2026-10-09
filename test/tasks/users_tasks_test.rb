require "test_helper"
require "rake"

class UsersTasksTest < ActiveSupport::TestCase
  setup do
    unless Rake::Task.task_defined?("users:create")
      Rake::Task.define_task(:environment)
      load Rails.root.join("lib/tasks/users.rake")
    end
    Rake::Task["users:create"].reenable
    @original_password = ENV.delete("USER_PASSWORD")
  end

  teardown do
    ENV["USER_PASSWORD"] = @original_password
  end

  test "creates a user with the role, taking the password from USER_PASSWORD" do
    ENV["USER_PASSWORD"] = "secret-password"

    out, _ = capture_io { create_user "Alice@Example.com", "agent" }

    user = User.find_by!(email_address: "alice@example.com")
    assert_equal "agent", user.role
    assert user.authenticate("secret-password")
    assert_match "Created agent alice@example.com", out
  end

  test "prompts for the password with hidden input when USER_PASSWORD is not set" do
    input = StringIO.new("prompted-password\n")
    def input.noecho
      @noecho_used = true
      yield self
    end

    with_stdin(input) { capture_io { create_user "bob@example.com", "customer" } }

    assert input.instance_variable_get(:@noecho_used)
    assert User.find_by!(email_address: "bob@example.com").authenticate("prompted-password")
  end

  test "rejects an unknown role" do
    ENV["USER_PASSWORD"] = "secret-password"

    assert_no_difference -> { User.count } do
      assert_aborts_with(/Unknown role "admin"\. Use customer or agent\./) { create_user "carol@example.com", "admin" }
    end
  end

  test "rejects an email that's already taken" do
    ENV["USER_PASSWORD"] = "secret-password"

    assert_no_difference -> { User.count } do
      assert_aborts_with(/customer@example\.com is already taken/) { create_user "CUSTOMER@example.com", "agent" }
    end
  end

  test "asks for USER_PASSWORD when there is no terminal to prompt on" do
    input = Object.new
    def input.noecho = raise(Errno::ENOTTY)

    with_stdin(input) do
      assert_aborts_with(/Set USER_PASSWORD/) { create_user "dave@example.com", "agent" }
    end
    assert_not User.exists?(email_address: "dave@example.com")
  end

  private
    def create_user(email, role)
      Rake::Task["users:create"].invoke(email, role)
    end

    def assert_aborts_with(message, &block)
      _, err = capture_io { assert_raises(SystemExit, &block) }
      assert_match message, err
    end

    def with_stdin(io)
      original, $stdin = $stdin, io
      yield
    ensure
      $stdin = original
    end
end
