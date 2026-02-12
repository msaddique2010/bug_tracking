class Bug < ApplicationRecord
  has_one_attached :image
  default_scope { order(created_at: :desc) }
  belongs_to :project
  belongs_to :user
end
