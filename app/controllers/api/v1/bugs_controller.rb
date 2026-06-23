module Api
  module V1
    class BugsController < ApiController
      before_action :set_project
      before_action :set_bug, only: %i[show update destroy assign resolve]

      # GET /api/v1/projects/:project_id/bugs
      def index
        @bugs = policy_scope(Bug).where(project_id: @project.id)

        if params[:status].present?
          @bugs = @bugs.where(status: params[:status])
        end
        if params[:bug_type].present?
          @bugs = @bugs.where(bug_type: params[:bug_type])
        end
        if params[:query].present?
          @bugs = @bugs.where("title LIKE ?", "%#{params[:query]}%")
        end

        render json: @bugs, status: :ok
      end

      # GET /api/v1/projects/:project_id/bugs/:id
      def show
        authorize @bug
        render json: @bug, status: :ok
      end

      # POST /api/v1/projects/:project_id/bugs
      def create
        @bug = @project.bugs.new(bug_params)
        @bug.creator = current_user
        authorize @bug

        if @bug.save
          render json: @bug, status: :created
        else
          render json: { errors: @bug.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/projects/:project_id/bugs/:id
      def update
        authorize @bug
        if @bug.update(bug_params)
          if @bug.saved_change_to_developer_id? && @bug.developer.present?
            NotificationMailer.bug_assigned(@bug.developer, @bug).deliver_later rescue nil
          end
          render json: @bug, status: :ok
        else
          render json: { errors: @bug.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/projects/:project_id/bugs/:id
      def destroy
        authorize @bug
        if @bug.destroy
          render json: { message: "Bug deleted successfully" }, status: :ok
        else
          render json: { errors: @bug.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/projects/:project_id/bugs/:id/assign
      def assign
        authorize @bug, :assign?
        if @bug.update(developer: current_user, status: 'started')
          NotificationMailer.bug_assigned(current_user, @bug).deliver_later rescue nil
          render json: @bug, status: :ok
        else
          render json: { errors: @bug.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/projects/:project_id/bugs/:id/resolve
      def resolve
        authorize @bug, :resolve?
        resolved_status = @bug.bug_type == 'bug' ? 'resolved' : 'completed'
        if @bug.update(status: resolved_status)
          render json: @bug, status: :ok
        else
          render json: { errors: @bug.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end

      def set_bug
        @bug = @project.bugs.find(params[:id])
      end

      def bug_params
        params.require(:bug).permit(:title, :description, :deadline, :bug_type, :status, :image, :developer_id, :project_id)
      end
    end
  end
end
