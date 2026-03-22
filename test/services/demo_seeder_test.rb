# frozen_string_literal: true

require "test_helper"

class DemoSeederTest < ActiveSupport::TestCase
  setup do
    DemoSeeder.reset!
  end

  test "reset restores the seeded submission set" do
    Submission.create!(
      applicant_name: "Late Add",
      applicant_email: "late@example.com",
      entity_type: "individual",
      outcome: "General Program Review",
      status: "Review",
      reason: "Created during the test.",
      decision_path: ["Individual selected"]
    )

    assert_equal DemoSeeder.seeded_count + 1, Submission.count

    DemoSeeder.reset!

    assert_equal DemoSeeder.seeded_count, Submission.count
    refute Submission.exists?(applicant_email: "late@example.com")
  end
end
