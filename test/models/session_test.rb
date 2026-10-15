require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "is destroyed with its user" do
    user = users(:customer)
    user.sessions.create!

    assert_difference -> { Session.count }, -1 do
      user.destroy
    end
  end
end
