require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "rejects an email address already taken in a different case" do
    user = User.new(email_address: "CUSTOMER@example.com", password: "secret-password", role: "customer")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "saves a customer or an agent with that role" do
    %w[ customer agent ].each do |role|
      user = User.create!(email_address: "new-#{role}@example.com", password: "secret-password", role: role)

      assert_equal role, user.reload.role
    end
  end

  test "rejects a role other than customer or agent" do
    user = User.new(email_address: "admin@example.com", password: "secret-password", role: "admin")

    assert_not user.valid?
    assert_includes user.errors[:role], "must be customer or agent"
  end

  test "rejects a user without a role" do
    user = User.new(email_address: "nobody@example.com", password: "secret-password")

    assert_not user.valid?
    assert_includes user.errors[:role], "must be customer or agent"
  end
end
