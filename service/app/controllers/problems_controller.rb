class ProblemsController < ApplicationController
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
      render json: {
        problem_id: @problem.id,
        model_answer: @problem.model_answer
      }, status: :ok
    else
      render json: { error: "Problem not found" }, status: :not_found
    end
  end

  private

  def set_problem
    @problem = Problem.find_by(id: params[:id], delete_flag: false)
  end
end