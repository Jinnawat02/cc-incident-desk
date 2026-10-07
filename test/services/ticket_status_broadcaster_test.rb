require "test_helper"

class TicketStatusBroadcasterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup { @ticket = tickets(:slow_login) }

  test "replaces the status badges on the ticket page and the customer's list" do
    @ticket.update!(status: :resolved)

    perform_enqueued_jobs do
      TicketStatusBroadcaster.new.status_changed(@ticket)
    end

    [ @ticket, [ @ticket.creator, :tickets ] ].each do |stream|
      streams = capture_turbo_stream_broadcasts(stream)
      assert_equal 1, streams.size
      assert_equal "replace", streams.first["action"]
      assert_equal "[data-ticket-status-id='#{@ticket.id}']", streams.first["targets"]
      assert_includes streams.first.to_html, "Resolved"
    end
  end
end
