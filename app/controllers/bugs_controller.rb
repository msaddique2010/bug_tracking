class BugsController < ApplicationController
  before_action :set_project
  before_action :set_bug, only: %i[ show edit update destroy ]

  def index
    @bugs = @project.bugs
  end

  def show
  end

  def new
    @bug = @project.bugs.new
  end

  def edit
  end

  def create
    @bug = @project.bugs.new(bug_params)
    @bug.user = current_user

    if @bug.save
      redirect_to @project, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @bug.update(bug_params)
      redirect_to project_bug_path(@project, @bug), notice: "Bug was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bug.destroy
    redirect_to project_path(@project), notice: "Bug was successfully destroyed."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_bug
    @bug = @project.bugs.find(params[:id])
  end

  def bug_params
    params.require(:bug).permit(:title, :deadline, :bug_type, :status)
  end
end
