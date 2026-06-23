json.extract! project, :id, :name, :description, :user_id, :created_at, :updated_at

json.users project.users do |user|
  json.extract! user, :id, :name, :email, :user_type
end

json.bugs project.bugs do |bug|
  json.extract! bug, :id, :title, :description, :deadline, :bug_type, :status, :user_id, :developer_id
  json.creator_name bug.creator.name
  json.developer_name bug.developer&.name
  json.image_url bug.image.attached? ? rails_blob_url(bug.image, only_path: true) : nil
end

json.url project_url(project, format: :json)
