module Api
  class SubmissionsController < BaseController
    def index
      render json: { submissions: SubmissionPresenter.collection(Submission.recent) }
    end

    def show
      submission = Submission.find(params[:id])
      render json: { submission: SubmissionPresenter.new(submission).as_json }
    end

    def create
      submission_hash = DecisionEngine.build_submission(answers: request_payload)
      submission = Submission.from_submission_hash(submission_hash)
      submission.save!
      render json: { submission: SubmissionPresenter.new(submission).as_json }, status: :created
    end

    private

    def request_payload
      body = request.raw_post.to_s
      return {} if body.empty?

      JSON.parse(body)
    end
  end
end
