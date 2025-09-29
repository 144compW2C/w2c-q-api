class Storage::AnswersController < ApplicationController
  before_action :set_problem, only: [:create]

  # POST /storage/answers
  def create
    answer = Answer.new(answer_params)
    answer.problem = @problem

    # 正解判定処理
    is_correct =  if @problem.is_multiple_choice
                    # 選択式 → optionsのcontentと一致チェック
                    @problem.options.exists?(content: answer.answer_text)
                  else
                    # 記述式 → model_answerと比較
                    answer.answer_text.strip == @problem.model_answer.strip
                  end

    answer.is_correct = is_correct

    if answer.save
      render json: { is_correct: is_correct }, status: :created
    else
      render json: { error: answer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_problem
    @problem = Problem.find(params[:fk_problems])
  end

  def answer_params
    params.permit(:fk_problems, :fk_users, :answer_text)
          .transform_keys do |key|
            { "fk_problems" => "problem_id", "fk_users" => "user_id" }[key] || key
          end
  end
end