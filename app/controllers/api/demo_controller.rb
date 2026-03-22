module Api
  class DemoController < BaseController
    def bootstrap
      render json: {
        app_name: 'DecisionDesk',
        questions: DecisionEngine.questions,
        labels: DecisionEngine.labels,
        seeded_count: DemoSeeder.seeded_count,
        current_count: Submission.count,
        outcome_count: DecisionEngine.outcome_catalog.size,
        question_branches: 3,
        submissions: SubmissionPresenter.collection(Submission.recent)
      }
    end

    def reset
      DemoSeeder.reset!
      render json: {
        ok: true,
        submissions: SubmissionPresenter.collection(Submission.recent),
        seeded_count: DemoSeeder.seeded_count
      }
    end
  end
end
