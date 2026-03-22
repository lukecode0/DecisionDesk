# frozen_string_literal: true

require "test_helper"

class ApiDemoTest < ActionDispatch::IntegrationTest
  setup do
    DemoSeeder.reset!
  end

  test "reset endpoint restores seeded submissions" do
    Submission.create!(
      applicant_name: "Temporary Applicant",
      applicant_email: "temp@example.com",
      entity_type: "individual",
      outcome: "General Program Review",
      status: "Review",
      reason: "Temporary test record.",
      decision_path: ["Individual selected"]
    )

    post "/api/reset"

    assert_response :success
    body = JSON.parse(response.body)

    assert_equal true, body["ok"]
    assert_equal DemoSeeder.seeded_count, body["seeded_count"]
    assert_equal DemoSeeder.seeded_count, body["submissions"].length
    refute Submission.exists?(applicant_email: "temp@example.com")
  end
end
