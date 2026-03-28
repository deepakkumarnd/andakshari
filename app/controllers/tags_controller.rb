class TagsController < ApplicationController
  def index
    tags = if params[:q].present?
      Tag.where("name ILIKE ?", "#{params[:q]}%").limit(10).pluck(:name)
    else
      Tag.limit(10).pluck(:name)
    end
    render json: tags
  end
end
