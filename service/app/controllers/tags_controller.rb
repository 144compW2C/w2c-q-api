# app/controllers/tags_controller.rb
class TagsController < ApplicationController
  def index
    tags = Tag.where(delete_flag: false).order(:id)
    render json: tags.as_json(only: [:id, :tag_name])
  end

  def show
    tag = Tag.find_by(id: params[:id], delete_flag: false)
    return render json: { error: 'Not Found' }, status: :not_found unless tag

    render json: tag.as_json(only: [:id, :tag_name])
  end
end
