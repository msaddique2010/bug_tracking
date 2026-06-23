json.extract! bug, :id, :project_id, :title, :description, :deadline, :bug_type, :status, :user_id, :developer_id, :created_at, :updated_at

json.creator do
  json.extract! bug.creator, :id, :name, :email, :user_type
end

if bug.developer
  json.developer do
    json.extract! bug.developer, :id, :name, :email, :user_type
  end
else
  json.developer nil
end

json.image_url bug.image.attached? ? rails_blob_url(bug.image, only_path: true) : nil
json.url project_bug_url(bug.project, bug, format: :json)
