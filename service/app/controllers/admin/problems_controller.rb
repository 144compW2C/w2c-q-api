# app/controllers/admin/problems_controller.rb
class Admin::ProblemsController < ApplicationController
  before_action :authenticate_request!
  before_action :authorize_reviewer!
  before_action :set_problem, only: [:show, :approve, :organize, :destroy]

  # GET /admin/problems
  # ステータス「承認待ち」の問題一覧
  def index
    waiting_status = Status.find_by(status_name: "承認待ち")
    return render json: { message: "承認待ちの問題はありません" }, status: :ok unless waiting_status

    problems = Problem.where(
      status_id: waiting_status.id,
      delete_flag: false
    )

    if problems.empty?
      return render json: { message: "承認待ちの問題はありません" }, status: :ok
    end

    results = problems.map do |p|
      {
        id:         p.id,
        title:      p.title,
        tags:       p.tag&.tag_name,
        status:     p.status&.status_name,
        level:      p.level,
        difficulty: p.difficulty,
        creator_id: p.creator_id
      }
    end

    render json: results, status: :ok
  end

  # GET /admin/problems/:id
  # 対象問題の詳細
  def show
    return render json: { error: "Problem not found" }, status: :not_found unless @problem

    result = {
      id:               @problem.id,
      title:            @problem.title,
      body:             @problem.body,
      tags:             @problem.tag&.tag_name,
      status:           @problem.status&.status_name,
      level:            @problem.level,
      difficulty:       @problem.difficulty,
      creator_id:       @problem.creator_id,
      reviewer_id:      @problem.reviewer_id,
      is_multiple_choice: @problem.is_multiple_choice,
      options:          build_options(@problem),
      model_answer:     @problem.model_answer,
      created_at:       @problem.created_at,
      updated_at:       @problem.updated_at,
      reviewed_at:      @problem.reviewed_at,
      delete_flag:      @problem.delete_flag
    }

    render json: result, status: :ok
  end

  # POST /admin/problems/:id/approve
  # 問題を「公開中」にして承認者・承認日時を保存
  def approve
    return render json: { error: "Problem not found" }, status: :not_found unless @problem

    published_status = Status.find_by(status_name: "公開中")
    unless published_status
      return render json: { error: "ステータス「公開中」が存在しません" }, status: :unprocessable_entity
    end

    @problem.status      = published_status
    @problem.reviewer_id = @current_user.id
    @problem.reviewed_at = Time.current

    if @problem.save
      render json: {
        id:     @problem.id,
        status: @problem.status.status_name
      }, status: :ok
    else
      render json: { error: @problem.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /admin/problems/:id/organize
  # タグ・ステータス・レベル・難易度などの整理
  def organize
    return render json: { error: "Problem not found" }, status: :not_found unless @problem

    ActiveRecord::Base.transaction do
      # tags（文字列として渡される想定: "HTML" など）
      if params[:tags].present?
        tag = Tag.find_by(tag_name: params[:tags])
        unless tag
          raise ActiveRecord::RecordInvalid.new(@problem), "指定されたタグが見つかりません"
        end
        @problem.tag = tag
      end

      # status（数値 or 文字列両方対応）
      if params[:status].present?
        status_param = params[:status]
        st =
          if status_param.to_s =~ /\A\d+\z/
            Status.find_by(id: status_param.to_i)
          else
            Status.find_by(status_name: status_param)
          end

        unless st
          raise ActiveRecord::RecordInvalid.new(@problem), "指定されたステータスが見つかりません"
        end
        @problem.status = st
      end

      # level / difficulty（数値想定）
      @problem.level      = params[:level]      if params.key?(:level)
      @problem.difficulty = params[:difficulty] if params.key?(:difficulty)

      @problem.save!
    end

    render json: { id: @problem.id }, status: :ok

  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # DELETE /admin/problems/:id
  # 論理削除（問題＋関連レコード）
  def destroy
    return render json: { error: "Problem not found" }, status: :not_found unless @problem

    ActiveRecord::Base.transaction do
      @problem.update!(delete_flag: true)

      # 関連レコードも論理削除（必要に応じて）
      @problem.options.update_all(delete_flag: true)        if @problem.respond_to?(:options)
      @problem.problem_assets.update_all(delete_flag: true) if @problem.respond_to?(:problem_assets)
      @problem.answers.update_all(delete_flag: true)        if @problem.respond_to?(:answers)
    end

    render json: { success: true }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_problem
    @problem = Problem.find_by(id: params[:id], delete_flag: false)
  end

  # options の整形
  def build_options(problem)
    return nil unless problem.is_multiple_choice

    opts = problem.options.where(delete_flag: false)
    return nil if opts.empty?

    opts.map do |op|
      {
        id:         op.id,
        option_name: op.option_name,
        content:    op.content,
        input_type: op.input_type
      }
    end
  end

  # 管理者（reviewer）のみ許可
  def authorize_reviewer!
    return if @current_user&.role == "reviewer"

    render json: { error: "権限がありません（管理者のみ）" }, status: :forbidden
  end
end
