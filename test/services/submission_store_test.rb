# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class SubmissionStoreTest < ActiveSupport::TestCase
  setup do
    DemoSeeder.reset!
  end

  test "defaults to the SQL backend" do
    assert_instance_of SubmissionStore::SqlBackend, SubmissionStore.current
  end

  test "file backend can create find and reset submissions" do
    Dir.mktmpdir do |dir|
      store_path = File.join(dir, "decisiondesk_submissions.json")

      with_env("DECISIONDESK_PERSISTENCE_BACKEND" => "file", "DECISIONDESK_FILE_STORE_PATH" => store_path) do
        repository = SubmissionStore.current
        repository.reset!(JSON.parse(File.read(Rails.root.join("db", "decisiondesk", "seeds.json"))))

        created = repository.create!(
          DecisionEngine.build_submission(
            answers: {
              "applicantName" => "Fallback User",
              "applicantEmail" => "fallback@example.com",
              "entityType" => "individual",
              "householdIncome" => "low",
              "veteran" => "no",
              "county" => "metro"
            }
          )
        )

        assert_equal "fallback@example.com", repository.find(created.id).applicant_email
        assert_equal DemoSeeder.seeded_count + 1, repository.count

        repository.reset!(JSON.parse(File.read(Rails.root.join("db", "decisiondesk", "seeds.json"))))

        assert_equal DemoSeeder.seeded_count, repository.count
      end
    end
  end

  private

  def with_env(values)
    original = {}
    values.each do |key, value|
      original[key] = ENV[key]
      ENV[key] = value
    end
    yield
  ensure
    values.each_key do |key|
      ENV[key] = original[key]
    end
  end
end
