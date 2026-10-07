require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "defaults to the customer role" do
    assert User.new.customer?
  end

  test "requires a valid email address" do
    user = User.new(email_address: "not-an-email", password: "password")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "requires a unique email address" do
    user = User.new(email_address: users(:customer).email_address.upcase, password: "password")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "rejects unknown roles" do
    user = User.new(email_address: "new@example.com", password: "password", role: "admin")

    assert_not user.valid?
    assert_includes user.errors[:role], "is not included in the list"
  end

  test "customers see only the tickets they created" do
    assert_equal [ tickets(:export_failure), tickets(:slow_login) ].sort, users(:customer).visible_tickets.sort
  end

  test "agents see every ticket" do
    assert_equal Ticket.all.sort, users(:agent).visible_tickets.sort
  end
end
