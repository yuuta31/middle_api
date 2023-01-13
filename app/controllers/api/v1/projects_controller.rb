class Api::V1::ProjectsController < ApplicationController
  def create
    project = End::Project.call(project_params.to_hash)
    project.save!
    render body: nil, status: :ok
  rescue StandardError => e
    logger.debug(e)
    render body: nil, status: :bad_request and return unless e.message

    render json: { message: e.message }, status: :bad_request
  end

  def update
    project = End::Project.call(project_params.to_h.merge({ id: params["id"] }))
    project.save!
    render body: nil, status: :ok
  rescue StandardError => e
    logger.debug(e)
    render body: nil, status: :bad_request and return unless e.message

    render json: { message: e.message }, status: :bad_request
  end

  def show
    project = End::Project.call({ id: params[:id] })
    project = project.find
    render json: project
  rescue StandardError => e
    logger.debug(e)
    render body: nil, status: :not_found and return unless e.message

    render json: { message: e.message }, status: :not_found
  end

  private

  def project_params = params.require(:project).permit(:name, :description)
end
