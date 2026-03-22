# frozen_string_literal: true

require "fileutils"
require "json"

class SubmissionStore
  def self.current
    backend_name = ENV.fetch("DECISIONDESK_PERSISTENCE_BACKEND", "sql").to_s
    return FileBackend.new if backend_name == "file"

    SqlBackend.new
  rescue StandardError
    FileBackend.new
  end

  class SqlBackend
    def recent
      Submission.recent.to_a
    end

    def count
      Submission.count
    end

    def find(id)
      Submission.find(id)
    end

    def create!(submission_hash)
      submission = Submission.from_submission_hash(submission_hash)
      submission.save!
      submission
    end

    def reset!(seed_payload)
      Submission.transaction do
        Submission.delete_all
        seed_payload.each do |row|
          submission = Submission.from_submission_hash(row)
          submission.id = row["id"] if row["id"]
          submission.save!
        end
      end
    end
  end

  class FileBackend
    def recent
      records.sort_by { |record| [timestamp_for(record), record.fetch("id", 0).to_i] }.reverse.map do |record|
        build_submission(record)
      end
    end

    def count
      records.count
    end

    def find(id)
      record = records.find { |row| row.fetch("id", nil).to_i == id.to_i }
      raise ActiveRecord::RecordNotFound, "Couldn't find Submission with 'id'=#{id}" if record.nil?

      build_submission(record)
    end

    def create!(submission_hash)
      submission = Submission.from_submission_hash(submission_hash)
      raise ActiveRecord::RecordInvalid, submission unless submission.valid?

      record = serialize_submission(submission).merge("id" => next_id)
      all_records = records
      all_records << record
      write_records(all_records)
      build_submission(record)
    end

    def reset!(seed_payload)
      write_records(seed_payload)
    end

    private

    def store_path
      ENV.fetch("DECISIONDESK_FILE_STORE_PATH", Rails.root.join("storage", "decisiondesk_submissions.json").to_s)
    end

    def records
      return [] unless File.exist?(store_path)

      JSON.parse(File.read(store_path))
    rescue JSON::ParserError
      []
    end

    def write_records(payload)
      FileUtils.mkdir_p(File.dirname(store_path))
      File.write(store_path, JSON.pretty_generate(payload))
    end

    def next_id
      records.map { |row| row.fetch("id", 0).to_i }.max.to_i + 1
    end

    def build_submission(record)
      submission = Submission.from_submission_hash(record)
      submission.id = record["id"] if record["id"]
      submission
    end

    def serialize_submission(submission)
      {
        "applicantName" => submission.applicant_name,
        "applicantEmail" => submission.applicant_email,
        "entityType" => submission.entity_type,
        "yearsActive" => submission.years_active,
        "annualRevenue" => submission.annual_revenue,
        "urgentNeed" => submission.urgent_need,
        "county" => submission.county,
        "npYearsActive" => submission.np_years_active,
        "servesYouth" => submission.serves_youth,
        "householdIncome" => submission.household_income,
        "veteran" => submission.veteran,
        "outcome" => submission.outcome,
        "status" => submission.status,
        "reason" => submission.reason,
        "decisionPath" => submission.decision_path,
        "createdAt" => (submission.created_at || Time.current).strftime("%Y-%m-%d %H:%M")
      }.compact
    end

    def timestamp_for(record)
      Submission.parse_created_at(record["createdAt"])
    end
  end
end
