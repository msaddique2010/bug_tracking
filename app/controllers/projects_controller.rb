class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

  # GET /projects or /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1 or /projects/1.json
  def show
    @bugs = @project.bugs.all
    @users = User.with_role(:developer)
  end

  # GET /projects/new
  def new
    @project = Project.new
    authorize @project
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)
    @project.user = current_user

    if @project.save
        redirect_to @project, notice: "Project was successfully created."
    else
        render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
      if @project.update(project_params)
        redirect_to @project, notice: "Project was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    authorize @project
    @project.destroy!

    redirect_to projects_path, notice: "Project was successfully destroyed.", status: :see_other
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:name, :description, :user_id)
    end
end
