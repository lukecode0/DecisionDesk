module Api
  class DemoController < BaseController
    def bootstrap
      repository = SubmissionStore.current
      render json: {
        app_name: 'DecisionDesk',
        questions: DecisionEngine.questions,
        labels: DecisionEngine.labels,
        seeded_count: DemoSeeder.seeded_count,
        current_count: repository.count,
        outcome_count: DecisionEngine.outcome_catalog.size,
        question_branches: 3,
        submissions: SubmissionPresenter.collection(repository.recent)
      }
    end

    def reset
      DemoSeeder.reset!
      repository = SubmissionStore.current
      render json: {
        ok: true,
        submissions: SubmissionPresenter.collection(repository.recent),
        seeded_count: DemoSeeder.seeded_count
      }
    end
  end
end
