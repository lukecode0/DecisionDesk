# frozen_string_literal: true

require "test_helper"

class SubmissionTest < ActiveSupport::TestCase
  test "from_submission_hash maps attributes and decision path" do
    submission = Submission.from_submission_hash(
      {
        "id" => 12,
        "applicantName" => "Jordan Lee",
        "applicantEmail" => "jordan@example.com",
        "entityType" => "small_business",
        "annualRevenue" => "gt250",
        "urgentNeed" => "yes",
        "county" => "metro",
        "outcome" => "Growth Line Fast-Track",
        "status" => "Eligible",
        "reason" => "Matched the fast-track route.",
        "decisionPath" => ["Small business selected", "Urgent request flagged"],
        "createdAt" => "2026-03-20 18:45"
      }
    )

    assert_equal "Jordan Lee", submission.applicant_name
    assert_equal "jordan@example.com", submission.applicant_email
    assert_equal "small_business", submission.entity_type
    assert_equal "gt250", submission.annual_revenue
    assert_equal "yes", submission.urgent_need
    assert_equal ["Small business selected", "Urgent request flagged"], submission.decision_path
    assert_equal Time.zone.parse("2026-03-20 18:45"), submission.created_at
  end
end
