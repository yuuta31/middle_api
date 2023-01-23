class Api::V1::ProjectsController < ApplicationController
  def create
    End::Project.new(project_params.to_hash).save!
    render body: nil, status: :ok
  rescue StandardError => e
    logger.debug(e)
    render body: nil, status: :bad_request and return unless e.message

    render json: { message: e.message }, status: :bad_request
  end

  def update
    End::Project.new(project_params.to_h.merge({ id: params["id"] })).save!
    render body: nil, status: :ok
  rescue StandardError => e
    logger.debug(e)
    render body: nil, status: :bad_request and return unless e.message

    render json: { message: e.message }, status: :bad_request
  end

  def show
    render json: End::Project.new({ id: params[:id] }).find
  rescue StandardError => e
    logger.debug(e)
    render body: nil, status: :not_found and return unless e.message

    render json: { message: e.message }, status: :not_found
  end

  private

  def project_params = params.require(:project).permit(:name, :description)
end
