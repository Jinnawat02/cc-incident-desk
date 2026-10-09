require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "saves only as customer or agent" do
    assert Role.new(name: "customer").valid?
    assert Role.new(name: "agent").valid?
    assert_not Role.new(name: "admin").valid?
  end
end
