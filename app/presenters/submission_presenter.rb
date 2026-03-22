# frozen_string_literal: true

class SubmissionPresenter
  def self.collection(scope)
    scope.map { |submission| new(submission).as_json }
  end

  def initialize(submission)
    @submission = submission
  end

  def as_json(*)
    {
      id: @submission.id,
      applicantName: @submission.applicant_name,
      applicantEmail: @submission.applicant_email,
      entityType: @submission.entity_type,
      yearsActive: @submission.years_active,
      annualRevenue: @submission.annual_revenue,
      urgentNeed: @submission.urgent_need,
      county: @submission.county,
      npYearsActive: @submission.np_years_active,
      servesYouth: @submission.serves_youth,
      householdIncome: @submission.household_income,
      veteran: @submission.veteran,
      outcome: @submission.outcome,
      status: @submission.status,
      reason: @submission.reason,
      decisionPath: @submission.decision_path,
      createdAt: formatted_created_at
    }.compact
  end

  private

  def formatted_created_at
    timestamp = @submission.created_at || Time.current
    timestamp.in_time_zone.strftime('%Y-%m-%d %H:%M')
  end
end
