# frozen_string_literal: true

require 'json'

class DemoSeeder
  class << self
    def reset!
      Submission.transaction do
        Submission.delete_all
        seed_payload.each do |row|
          submission = Submission.from_submission_hash(row)
          submission.id = row['id'] if row['id']
          submission.save!
        end
      end
    end

    def seeded_count
      seed_payload.count
    end

    private

    def seed_payload
      @seed_payload ||= JSON.parse(File.read(seed_path))
    end

    def seed_path
      Rails.root.join('db', 'decisiondesk', 'seeds.json')
    end
  end
end
