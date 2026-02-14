class Bug < ApplicationRecord
  validates :title, uniqueness: { scope: :project_id }
  validates_presence_of :title, :status, :bug_type
  has_one_attached :image
  default_scope { order(created_at: :desc) }
  belongs_to :project
  belongs_to :user
end
