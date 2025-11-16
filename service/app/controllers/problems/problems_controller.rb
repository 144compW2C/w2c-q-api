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
        correct_option = @problem.options.find_by(content: @problem.model_answer)
        render json: {
          problem_id:  @problem.id,
          user_answer: correct_option&.content
        }, status: :ok
      else
        render json: {
          problem_id:  @problem.id,
          user_answer: @problem.model_answer
        }, status: :ok
      end
    else
      render json: { error: "Problem not found" }, status: :not_found
    end
  end

  # ✅ GET /createProblem/:id
  def create_problem
    user = User.find_by(id: params[:id], delete_flag: false)
    return render json: { error: "User not found" }, status: :not_found unless user

    problems = Problem.where(
      creator_id:  user.id,
      delete_flag: false
    ).order(created_at: :desc)

    # 問題が 0 件のとき
    if problems.empty?
      return render json: { message: "作成された問題はありません" }, status: :ok
    end

    result = problems.map do |p|
      {
        id:          p.id,
        title:       p.title,
        tags:        p.tag&.tag_name,
        status:      p.status&.status_name,
        level:       p.level,
        difficulty:  p.difficulty,
        creator_id:  p.creator_id
      }
    end

    render json: result, status: :ok
  end

  private

  def set_problem
    @problem = Problem.find_by(id: params[:id], delete_flag: false)
  end
end
