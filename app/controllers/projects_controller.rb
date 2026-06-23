class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]
  before_action :authorize_project, only: %i[ show edit update destroy ]

  # GET /projects or /projects.json
  def index
    @projects = policy_scope(Project)
    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  # GET /projects/1 or /projects/1.json
  def show
    @bugs = @project.bugs.all
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
    authorize @project
    @assignable_users = User.where(user_type: [:developer, :qa])
  end

  # GET /projects/1/edit
  def edit
    @assignable_users = User.where(user_type: [:developer, :qa])
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)
    @project.user = current_user
    authorize @project

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        @assignable_users = User.where(user_type: [:developer, :qa])
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        notify_project_users(@project, "updated")
        format.html { redirect_to @project, notice: "Project was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @project }
      else
        @assignable_users = User.where(user_type: [:developer, :qa])
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    notify_project_users(@project, "deleted")
    @project.destroy!

    respond_to do |format|
      format.html { redirect_to projects_path, notice: "Project was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

    def authorize_project
      authorize @project
    end

    def project_params
      params.require(:project).permit(:name, :description, project_users_attributes: [:id, :user_id, :_destroy])
    end

    def notify_project_users(project, action)
      project.users.each do |user|
        NotificationMailer.project_update(user, project, action).deliver_later
      end
    end
end
