module Api
  class SubmissionsController < BaseController
    def index
      render json: { submissions: SubmissionPresenter.collection(repository.recent) }
    end

    def show
      submission = repository.find(params[:id])
      render json: { submission: SubmissionPresenter.new(submission).as_json }
    end

    def create
      submission_hash = DecisionEngine.build_submission(answers: request_payload)
      submission = repository.create!(submission_hash)
      render json: { submission: SubmissionPresenter.new(submission).as_json }, status: :created
    end

    private

    def repository
      @repository ||= SubmissionStore.current
    end

    def request_payload
      body = request.raw_post.to_s
      return {} if body.empty?

      JSON.parse(body)
    end
  end
end
