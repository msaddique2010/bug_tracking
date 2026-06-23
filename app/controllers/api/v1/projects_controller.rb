module Api
  module V1
    class ProjectsController < ApiController
      before_action :set_project, only: %i[show update destroy]

      # GET /api/v1/projects
      def index
        @projects = policy_scope(Project)
        render json: @projects, status: :ok
      end

      # GET /api/v1/projects/:id
      def show
        authorize @project
        # Render the project along with its bugs
        render json: @project.as_json(include: :bugs), status: :ok
      end

      # POST /api/v1/projects
      def create
        @project = Project.new(project_params)
        @project.user = current_user
        authorize @project

        if @project.save
          render json: @project, status: :created
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/projects/:id
      def update
        authorize @project
        if @project.update(project_params)
          notify_project_users(@project, "updated")
          render json: @project, status: :ok
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/projects/:id
      def destroy
        authorize @project
        notify_project_users(@project, "deleted")
        if @project.destroy
          render json: { message: "Project deleted successfully" }, status: :ok
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_params
        params.require(:project).permit(:name, :description, project_users_attributes: [:id, :user_id, :_destroy])
      end

      def notify_project_users(project, action)
        project.users.each do |user|
          NotificationMailer.project_update(user, project, action).deliver_later
        end
      rescue => e
        Rails.logger.error "Failed to send mail: #{e.message}"
      end
    end
  end
end
