class BugsController < ApplicationController
  before_action :set_project
  before_action :set_bug, only: %i[ show edit update destroy assign resolve ]
  before_action :set_projects_for_select, only: %i[ new edit create update ]

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

    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  def show
    authorize @bug
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  def new
    @bug = @project.bugs.new
    authorize @bug
  end

  def edit
    authorize @bug
  end

  def create
    @bug = @project.bugs.new(bug_params)
    @bug.creator = current_user
    authorize @bug

    respond_to do |format|
      if @bug.save
        format.html { redirect_to project_bugs_path(@project), notice: "Bug was successfully created." }
        format.json { render :show, status: :created, location: [@project, @bug] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bug.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @bug
    respond_to do |format|
      if @bug.update(bug_params)
        if @bug.saved_change_to_developer_id? && @bug.developer.present?
          NotificationMailer.bug_assigned(@bug.developer, @bug).deliver_later
        end
        format.html { redirect_to project_bug_path(@project, @bug), notice: "Bug was successfully updated." }
        format.json { render :show, status: :ok, location: [@project, @bug] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bug.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @bug
    @bug.destroy
    respond_to do |format|
      format.html { redirect_to project_bugs_path(@project), notice: "Bug was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Custom action for Developer to assign bug to themselves
  def assign
    authorize @bug, :assign?
    respond_to do |format|
      if @bug.update(developer: current_user, status: 'started')
        NotificationMailer.bug_assigned(current_user, @bug).deliver_later
        format.html { redirect_to project_bug_path(@project, @bug), notice: "Bug is successfully assigned to you and started." }
        format.json { render :show, status: :ok, location: [@project, @bug] }
      else
        format.html { redirect_to project_bug_path(@project, @bug), alert: "Unable to assign bug." }
        format.json { render json: @bug.errors, status: :unprocessable_entity }
      end
    end
  end

  # Custom action for Developer to resolve the bug
  def resolve
    authorize @bug, :resolve?
    resolved_status = @bug.bug_type == 'bug' ? 'resolved' : 'completed'
    respond_to do |format|
      if @bug.update(status: resolved_status)
        format.html { redirect_to project_bug_path(@project, @bug), notice: "Bug has been marked as #{resolved_status}." }
        format.json { render :show, status: :ok, location: [@project, @bug] }
      else
        format.html { redirect_to project_bug_path(@project, @bug), alert: "Unable to resolve bug." }
        format.json { render json: @bug.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_bug
    @bug = @project.bugs.find(params[:id])
  end

  def set_projects_for_select
    if current_user.has_role?(:qa)
      @projects_for_select = Project.all
    elsif current_user.has_role?(:manager)
      @projects_for_select = Project.where(user_id: current_user.id)
    else
      @projects_for_select = Project.none
    end
  end

  def bug_params
    params.require(:bug).permit(:title, :description, :deadline, :bug_type, :status, :image, :developer_id, :project_id)
  end
end
