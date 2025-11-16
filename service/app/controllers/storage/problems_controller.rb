class Storage::ProblemsController < ApplicationController
  before_action :authenticate_request!
  before_action :authorize_admin!, only: [:create, :update]
  before_action :set_problem, only: [:update]

  def index
    problems = Problem.where(delete_flag: false).includes(:tag, :status).order(:id)
    render json: problems.as_json(
      only: [:id, :title, :level, :difficulty, :is_multiple_choice, :model_answer],
      include: {
        tag:    { only: [:id, :tag_name] },
        status: { only: [:id, :status_name] }
      }
    )
  end

  # POST /storage/problems
  def create
    tag     = resolve_tag
    status  = resolve_status

    unless tag && status
      return render json: { error: "タグまたはステータスが見つかりません" }, status: :unprocessable_entity
    end

    problem = Problem.new(
      title:              problem_params[:title],
      body:               problem_params[:body],
      tag:                tag,
      status:             status,
      creator:            @current_user,
      level:              problem_params[:level],
      difficulty:         problem_params[:difficulty],
      is_multiple_choice: to_bool(problem_params[:is_multiple_choice]),
      model_answer:       problem_params[:answer],
      delete_flag:        problem_params.fetch(:delete_flag, false)
    )

    ActiveRecord::Base.transaction do
      problem.save!

      # 選択式なら options を作成
      if problem.is_multiple_choice && problem_params[:options].present?
        problem_params[:options].each_with_index do |content, idx|
          problem.options.create!(
            input_type:  "choice",
            option_name: option_label(idx),  # A, B, C...
            content:     content
          )
        end

        # 正解（answer）が options に含まれているか検証
        unless problem.options.exists?(content: problem.model_answer)
          raise ActiveRecord::RecordInvalid.new(problem), "answer が options に含まれていません"
        end
      end
    end

    render json: { id: problem.id }, status: :created

  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.presence || [e.message] }, status: :unprocessable_entity
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # PUT /storage/problems/:id
  def update
    tag    = resolve_tag
    status = resolve_status

    ActiveRecord::Base.transaction do
      # 更新用の属性（nil の場合は元の値を維持）
      attrs = {
        title:              problem_params[:title].presence      || @problem.title,
        body:               problem_params[:body].presence       || @problem.body,
        tag:                tag                                  || @problem.tag,
        status:             status                               || @problem.status,
        level:              problem_params[:level]               || @problem.level,
        difficulty:         problem_params[:difficulty]          || @problem.difficulty,
        is_multiple_choice: problem_params.key?(:is_multiple_choice) ? to_bool(problem_params[:is_multiple_choice]) : @problem.is_multiple_choice,
        model_answer:       problem_params[:answer].presence     || @problem.model_answer,
        delete_flag:        problem_params.key?(:delete_flag) ? problem_params[:delete_flag] : @problem.delete_flag,
        lock_version:       problem_params[:lock_version]        # ← 楽観ロック
      }.compact

      unless @problem.update(attrs)
        raise ActiveRecord::RecordInvalid.new(@problem)
      end

      # 選択式のときだけ options を更新
      if @problem.is_multiple_choice
        if problem_params[:options].present?
          # 既存を全削除してから再作成
          @problem.options.destroy_all

          problem_params[:options].each_with_index do |content, idx|
            @problem.options.create!(
              input_type:  "choice",
              option_name: option_label(idx),
              content:     content
            )
          end

          # answer が options に含まれているか確認
          unless @problem.options.exists?(content: @problem.model_answer)
            raise ActiveRecord::RecordInvalid.new(@problem), "answer が options に含まれていません"
          end
        end
      else
        # 記述式に変更された場合は options を全削除
        @problem.options.destroy_all if @problem.options.exists?
      end
    end

    render json: { id: @problem.id }, status: :ok

  rescue ActiveRecord::StaleObjectError
    render json: { error: "他のユーザーによって更新されました。画面を再読み込みしてからやり直してください。" }, status: :conflict
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.presence || [e.message] }, status: :unprocessable_entity
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_problem
    # delete_flag = false のみ編集対象（SoftDeletable の active を利用）
    @problem = Problem.active.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Problem not found" }, status: :not_found
  end

  # tags: "CSS" / fk_tags: 3 の両対応
  def resolve_tag
    if problem_params[:fk_tags].present?
      Tag.find_by(id: problem_params[:fk_tags])
    elsif problem_params[:tags].present?
      Tag.find_by(tag_name: problem_params[:tags])
    end
  end

  # status: 2 / "承認待ち" の両対応
  def resolve_status
    s = problem_params[:status]
    return Status.find_by(id: s) if s.is_a?(Integer) || s.to_s =~ /\A\d+\z/
    return Status.find_by(status_name: s) if s.present?
    nil
  end

  def option_label(index)
    ("A".ord + index).chr # 0->A, 1->B...
  end

  def to_bool(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end

  # 強いパラメータ: options は配列、lock_version を追加
  def problem_params
    params.permit(
      :title, :body, :tags, :fk_tags, :status, :level, :difficulty,
      :is_multiple_choice, :answer, :delete_flag, :lock_version,
      options: []
    ).tap do |p|
      # 数値文字列 → 整数へ変換
      p[:fk_tags] = p[:fk_tags].to_i if p[:fk_tags].present?
      p[:status]  = p[:status].to_i  if p[:status].is_a?(String) && p[:status] =~ /\A\d+\z/
    end
  end
  # 管理者（レビュアー）だけ許可するフィルタ
  def authorize_admin!
    # @current_user は authenticate_request! でセットされている想定
    unless @current_user&.role == "reviewer"
      render json: { error: "権限がありません（管理者のみ実行可能です）" }, status: :forbidden
    end
  end
end