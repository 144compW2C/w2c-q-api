module Problems
  class OptionsController < ApplicationController
    before_action :set_problem

    # GET /options/:id   (id = problem_id)
    def index
      # 問題が見つからなければ set_problem で 404 を返している
      opts = @problem.options.where(delete_flag: false).order(:id)

      result = opts.map do |o|
        {
          id:          o.id,
          problem_id:  o.problem_id,
          option_name: o.option_name,
          content:     o.content,
          input_type:  o.input_type
        }
      end

      render json: result, status: :ok
    end

    private

    def set_problem
      @problem = Problem.find_by(id: params[:id], delete_flag: false)
      return if @problem

      render json: { error: "Problem not found" }, status: :not_found
    end
  end
end
