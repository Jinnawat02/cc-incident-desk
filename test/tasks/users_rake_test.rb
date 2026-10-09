require "test_helper"
require "rake"

class UsersRakeTest < ActiveSupport::TestCase
  setup do
    unless Rake::Task.task_defined?("users:create")
      Rake::Task.define_task(:environment)
      load Rails.root.join("lib/tasks/users.rake")
    end
    @task = Rake::Task["users:create"]
  end

  teardown { @task.reenable }

  test "creates a user with a role and the password from PASSWORD" do
    with_password("s3cret-pass") do
      assert_output(/Created agent new-agent@example.com/) { @task.invoke("New-Agent@example.com", "agent") }
    end

    user = User.find_by!(email_address: "new-agent@example.com")
    assert_equal "agent", user.role
    assert user.authenticate("s3cret-pass")
  end

  test "rejects an unknown role" do
    error = assert_raises(SystemExit) do
      with_password("s3cret-pass") { capture_io { @task.invoke("someone@example.com", "admin") } }
    end

    assert_not error.success?
    assert_not User.exists?(email_address: "someone@example.com")
  end

  test "rejects an email that's already taken" do
    _out, err = capture_io do
      assert_raises(SystemExit) { with_password("s3cret-pass") { @task.invoke("Customer@example.com", "customer") } }
    end

    assert_match "already exists", err
  end

  test "requires a password when not running interactively" do
    _out, err = capture_io do
      assert_raises(SystemExit) { with_password(nil) { @task.invoke("someone@example.com", "customer") } }
    end

    assert_match "PASSWORD", err
    assert_not User.exists?(email_address: "someone@example.com")
  end

  private
    def with_password(password)
      previous, ENV["PASSWORD"] = ENV["PASSWORD"], password
      yield
    ensure
      ENV["PASSWORD"] = previous
    end
end
