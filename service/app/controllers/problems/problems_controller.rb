class Problems::ProblemsController < ApplicationController
  before_action :set_problem, only: [:show, :model_answer]

  # GET /problems
  def index
    problems = Problem.where(delete_flag: false)
    render json: problems, status: :ok
  end

  # GET /problems/:id
  def show
    render json: @problem, status: :ok
  end

  # GET /problems/modelAnswers/:id
  def model_answer
    if @problem
      if @problem.is_multiple_choice
        # 選択肢タイプのとき → 正解の option を探す
        correct_option = @problem.options.find_by(content: @problem.model_answer)
        render json: {
          problem_id: @problem.id,
          user_answer: correct_option&.content
        }, status: :ok
      else
        # 記述式のとき → そのまま model_answer を返す
        render json: {
          problem_id: @problem.id,
          user_answer: @problem.model_answer
        }, status: :ok
      end
    else
      render json: { error: "Problem not found" }, status: :not_found
    end
  end

  private

  def set_problem
    @problem = Problem.find_by(id: params[:id], delete_flag: false)
  end
end