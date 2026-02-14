class Bug < ApplicationRecord
  validates :title, uniqueness: { scope: :project_id }
  has_one_attached :image
  default_scope { order(created_at: :desc) }
  belongs_to :project
  belongs_to :user
end
