# frozen_string_literal: true

require 'json'
require 'time'

class Submission < ApplicationRecord
  scope :recent, -> { order(created_at: :desc, id: :desc) }

  validates :applicant_name, :applicant_email, :entity_type, :outcome, :status, :reason, presence: true

  def self.from_submission_hash(hash)
    payload = hash.respond_to?(:with_indifferent_access) ? hash.with_indifferent_access : hash
    new(
      applicant_name: payload[:applicantName],
      applicant_email: payload[:applicantEmail],
      entity_type: payload[:entityType],
      years_active: payload[:yearsActive],
      annual_revenue: payload[:annualRevenue],
      urgent_need: payload[:urgentNeed],
      county: payload[:county],
      np_years_active: payload[:npYearsActive],
      serves_youth: payload[:servesYouth],
      household_income: payload[:householdIncome],
      veteran: payload[:veteran],
      outcome: payload[:outcome],
      status: payload[:status],
      reason: payload[:reason],
      decision_path: payload[:decisionPath],
      created_at: parse_created_at(payload[:createdAt]),
      updated_at: parse_created_at(payload[:createdAt])
    )
  end

  def self.parse_created_at(value)
    return Time.current if value.blank?

    Time.zone.parse(value.to_s) || Time.current
  rescue StandardError
    Time.current
  end

  def decision_path
    raw = self[:decision_path_json]
    return [] if raw.blank?

    JSON.parse(raw)
  rescue JSON::ParserError
    []
  end

  def decision_path=(value)
    self[:decision_path_json] = Array(value).to_json
  end
end
