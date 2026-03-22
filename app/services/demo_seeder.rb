# frozen_string_literal: true

require 'json'

class DemoSeeder
  class << self
    def reset!
      SubmissionStore.current.reset!(seed_payload)
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
