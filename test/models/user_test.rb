require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "email_address is unique regardless of case" do
    user = build_user(email_address: "CUSTOMER@example.com", role: "customer")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "requires a valid email_address" do
    assert_not build_user(email_address: "not-an-email", role: "customer").valid?
  end

  test "is valid with a customer or agent role" do
    User::ROLES.each do |role|
      user = build_user(role: role)
      assert user.valid?, user.errors.full_messages.to_sentence
      assert_equal role, user.role
    end
  end

  test "requires a role" do
    user = User.new(email_address: "new@example.com", password: "secret")

    assert_not user.valid?
    assert_includes user.errors[:role], "must be one of: customer or agent"
  end

  test "rejects more than one role" do
    user = build_user(role: "customer")
    user.add_role("agent")

    assert_not user.valid?
  end

  test "role returns the fixture roles" do
    assert_equal "customer", users(:customer).role
    assert_equal "agent", users(:agent).role
  end

  private
    def build_user(email_address: "new@example.com", role:)
      User.new(email_address: email_address, password: "secret").tap { |user| user.add_role(role) }
    end
end
