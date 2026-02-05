class Bug < ApplicationRecord
  default_scope { order(created_at: :desc) }
  belongs_to :project
  belongs_to :user
end
