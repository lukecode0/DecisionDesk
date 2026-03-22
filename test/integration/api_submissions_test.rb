# frozen_string_literal: true

require "test_helper"

class ApiSubmissionsTest < ActionDispatch::IntegrationTest
  setup do
    DemoSeeder.reset!
  end

  test "creating a submission persists it and returns it through the listing endpoint" do
    post "/api/submissions",
         params: {
           applicantName: "Casey Rivera",
           applicantEmail: "casey@example.com",
           entityType: "individual",
           householdIncome: "low",
           veteran: "no",
           county: "metro"
         }.to_json,
         headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :created

    body = JSON.parse(response.body)
    assert_equal "Casey Rivera", body.dig("submission", "applicantName")
    assert_equal DemoSeeder.seeded_count + 1, Submission.count

    get "/api/submissions"

    assert_response :success
    listing = JSON.parse(response.body)
    assert_includes listing["submissions"].map { |submission| submission["applicantEmail"] }, "casey@example.com"
  end
end
