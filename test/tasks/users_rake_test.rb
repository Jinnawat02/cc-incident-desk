require "test_helper"
require "rake"

class UsersRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("users:create")
    Rake::Task["users:create"].reenable
  end

  test "creates a user with the given role, reading the password from PASSWORD" do
    out, _ = capture_io do
      with_password("secret123") { Rake::Task["users:create"].invoke("New@Example.com", "agent") }
    end

    user = User.find_by!(email_address: "new@example.com")
    assert user.has_role?(:agent)
    assert user.authenticate("secret123")
    assert_match "Created agent new@example.com", out
  end

  test "rejects an unknown role" do
    assert_no_difference -> { User.count } do
      _, err = capture_io do
        assert_raises(SystemExit) do
          with_password("secret123") { Rake::Task["users:create"].invoke("new@example.com", "admin") }
        end
      end

      assert_match "Role must be customer or agent", err
    end
  end

  test "rejects an email that is already taken" do
    assert_no_difference -> { User.count } do
      _, err = capture_io do
        assert_raises(SystemExit) do
          with_password("secret123") { Rake::Task["users:create"].invoke("customer@example.com", "agent") }
        end
      end

      assert_match "Email address has already been taken", err
    end
  end

  test "requires an email and a role" do
    _, err = capture_io do
      assert_raises(SystemExit) { Rake::Task["users:create"].invoke }
    end

    assert_match "Usage: bin/rails \"users:create[email,role]\"", err
  end

  test "asks for PASSWORD when there is no terminal to prompt on" do
    _, err = capture_io do
      assert_raises(SystemExit) do
        with_stdin(StringIO.new) do
          with_password(nil) { Rake::Task["users:create"].invoke("new@example.com", "agent") }
        end
      end
    end

    assert_match "Set PASSWORD", err
  end

  private
    def with_password(password)
      previous, ENV["PASSWORD"] = ENV["PASSWORD"], password
      yield
    ensure
      ENV["PASSWORD"] = previous
    end

    def with_stdin(io)
      previous, $stdin = $stdin, io
      yield
    ensure
      $stdin = previous
    end
end
