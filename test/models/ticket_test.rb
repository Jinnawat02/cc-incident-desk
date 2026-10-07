require "test_helper"

class TicketTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @ticket = Ticket.new(
      title: "Printer is on fire",
      description: "Smoke is coming out of the office printer.",
      severity: :urgent,
      creator: users(:customer)
    )
  end

  test "is valid with a title, description, severity and creator" do
    assert @ticket.valid?
  end

  test "defaults to the open status" do
    assert @ticket.open?
  end

  test "has no assignee by default" do
    assert_nil @ticket.assignee
  end

  test "requires a title of at least 5 characters" do
    @ticket.title = "Oops"

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:title], "is too short (minimum is 5 characters)"
  end

  test "requires a description of at least 10 characters" do
    @ticket.description = "Broken"

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:description], "is too short (minimum is 10 characters)"
  end

  test "requires a known severity" do
    @ticket.severity = "catastrophic"

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:severity], "is not included in the list"
  end

  test "requires a severity" do
    @ticket.severity = nil

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:severity], "is not included in the list"
  end

  test "requires a creator" do
    @ticket.creator = nil

    assert_not @ticket.valid?
  end

  test "recent_first orders newest tickets first" do
    newest = tickets(:slow_login)
    newest.update!(created_at: 1.minute.from_now)

    assert_equal newest, Ticket.recent_first.first
  end

  test "high and urgent tickets are high priority" do
    assert tickets(:export_failure).high_priority?
    assert tickets(:checkout_error).high_priority?
    assert_not tickets(:slow_login).high_priority?
    assert_not tickets(:invoice_typo).high_priority?
  end

  test "accepts an agent as assignee" do
    @ticket.assignee = users(:agent)

    assert @ticket.valid?
  end

  test "rejects a customer as assignee" do
    @ticket.assignee = users(:other_customer)

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:assignee], "must be an agent"
  end

  test "rejects an assignee that does not exist" do
    @ticket.assignee_id = User.maximum(:id) + 1

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:assignee], "must be an agent"
  end

  test "creating a high or urgent ticket schedules an escalation in 15 minutes" do
    freeze_time

    %i[ high urgent ].each do |severity|
      ticket = Ticket.create!(@ticket.attributes.compact.merge("severity" => severity.to_s))

      assert_enqueued_with job: TicketEscalationJob, args: [ ticket ], at: 15.minutes.from_now
    end
  end

  test "creating a low or medium ticket schedules no escalation" do
    %i[ low medium ].each do |severity|
      assert_no_enqueued_jobs only: TicketEscalationJob do
        Ticket.create!(@ticket.attributes.compact.merge("severity" => severity.to_s))
      end
    end
  end

  test "updating a high priority ticket schedules no further escalation" do
    assert_no_enqueued_jobs only: TicketEscalationJob do
      tickets(:export_failure).update!(title: "Cannot export any report")
    end
  end

  test "escalatable only while high priority, open, unassigned and not yet escalated" do
    ticket = tickets(:slow_login)
    ticket.severity = :urgent
    assert ticket.escalatable?

    assert_not ticket.dup.tap { |t| t.severity = :medium }.escalatable?
    assert_not ticket.dup.tap { |t| t.status = :in_progress }.escalatable?
    assert_not ticket.dup.tap { |t| t.assignee = users(:agent) }.escalatable?
    assert_not ticket.dup.tap { |t| t.escalated_at = Time.current }.escalatable?
  end

  test "overdue while escalated, open and unassigned" do
    ticket = tickets(:checkout_error)
    assert ticket.overdue?

    ticket.assignee = users(:agent)
    assert_not ticket.overdue?

    ticket.assignee = nil
    ticket.status = :resolved
    assert_not ticket.overdue?

    assert_not tickets(:slow_login).overdue?
  end
end
