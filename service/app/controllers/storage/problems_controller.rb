class Storage::ProblemsController < ApplicationController
  before_action :authenticate_request!

  # POST /storage/problems
  #
  # 受け付ける例:
  # {
  #   "title": "CSSの書き方",
  #   "body": "クラスセレクタの書き方は？",
  #   "tags": "CSS",            # もしくは fk_tags: 2
  #   "status": 1,              # もしくは "承認待ち"
  #   "level": 1,
  #   "difficulty": 1,
  #   "is_multiple_choice": true,
  #   "options": [".class", "#id", "class:", "div.class"],
  #   "answer": ".class",       # 記述式なら模範解答テキスト、選択式なら正解のcontent
  #   "delete_flag": false
  # }
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
      is_multiple_choice: problem_params[:is_multiple_choice],
      model_answer:       problem_params[:answer],   # 記述式/選択式ともにここへ
      delete_flag:        problem_params.fetch(:delete_flag, false)
    )

    ActiveRecord::Base.transaction do
      problem.save!

      # 選択式なら options を作成
      if problem.is_multiple_choice && problem_params[:options].present?
        problem_params[:options].each_with_index do |content, idx|
          Option.create!(
            problem:     problem,
            input_type:  "choice",           # 固定
            option_name: option_label(idx),  # A, B, C, ...
            content:     content
          )
        end

        # 正解（answer）が options に含まれているか軽く検証（含まれてなければ400）
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

  private

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
    # 指定なし→承認待ちをデフォルト（なければ作る）
    Status.find_or_create_by!(status_name: "承認待ち")
  end

  def option_label(index)
    ("A".ord + index).chr # 0->A, 1->B...
  end

  # 強いパラメータ: options は配列
  def problem_params
    params.permit(
      :title, :body, :tags, :fk_tags, :status, :level, :difficulty,
      :is_multiple_choice, :answer, :delete_flag
    ).tap do |p|
      p[:options] = Array(params[:options]) if params.key?(:options)
      # 数値文字列→整数へ
      p[:fk_tags] = p[:fk_tags].to_i if p[:fk_tags].present?
      p[:status]  = p[:status].to_i  if p[:status].is_a?(String) && p[:status] =~ /\A\d+\z/
    end
  end
end