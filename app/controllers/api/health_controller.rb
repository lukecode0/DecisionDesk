module Api
  class HealthController < BaseController
    def show
      render json: { ok: true, submissions: store.all.count }
    end
  end
end
