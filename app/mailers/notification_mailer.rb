class NotificationMailer < ApplicationMailer
  default from: 'notifications@bugtracker.com'

  def bug_assigned(user, bug)
    @user = user
    @bug = bug
    mail(to: @user.email, subject: "Bug Assigned: #{@bug.title}")
  end

  def project_update(user, project, action)
    @user = user
    @project = project
    @action = action
    mail(to: @user.email, subject: "Project Update: #{@project.name} has been #{@action}")
  end
end
