module Api
  class BaseController < ActionController::API
    rescue_from JSON::ParserError do
      render json: { error: 'Invalid JSON payload' }, status: :bad_request
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render json: { error: 'Validation failed', detail: error.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: 'Not found' }, status: :not_found
    end

    rescue_from StandardError do |error|
      Rails.logger.error(error.full_message)
      render json: { error: 'Internal server error', detail: error.message }, status: :internal_server_error
    end
  end
end
