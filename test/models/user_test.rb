require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "email_address is unique regardless of case" do
    user = User.new(email_address: "Customer@Example.com", password: "secret123", role: "customer")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "is created with a customer or agent role" do
    user = User.create!(email_address: "new@example.com", password: "secret123", role: "agent")

    assert user.reload.has_role?(:agent)
    assert_equal "agent", user.role
  end

  test "rejects an unknown role" do
    user = User.new(email_address: "new@example.com", password: "secret123", role: "admin")

    assert_not user.valid?
    assert_includes user.errors[:role], "must be customer or agent"
    assert_no_difference -> { Role.count } do
      user.save
    end
  end

  test "requires a role" do
    user = User.new(email_address: "new@example.com", password: "secret123")

    assert_not user.valid?
    assert_includes user.errors[:role], "must be customer or agent"
  end

  test "role of fixtures" do
    assert users(:customer).role.customer?
    assert users(:agent).role.agent?
  end
end
