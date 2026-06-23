class Project < ApplicationRecord
  belongs_to :user
  has_many :bugs, dependent: :destroy

  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users

  accepts_nested_attributes_for :project_users, allow_destroy: true

  validates :name, presence: true, uniqueness: true
end
