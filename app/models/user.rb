class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :user_type, { developer: 'developer', manager: 'manager', qa: 'qa' }

  validates :name, presence: true
  validates :user_type, presence: true

  # Projects managed by this user (Manager role)
  has_many :projects, dependent: :destroy

  # Projects this user (Developer or QA) is assigned to
  has_many :project_users, dependent: :destroy
  has_many :assigned_projects, through: :project_users, source: :project

  # Bugs reported by this user (QA/Manager role)
  has_many :created_bugs, class_name: 'Bug', foreign_key: 'user_id', dependent: :destroy

  # Bugs assigned to this user (Developer role)
  has_many :assigned_bugs, class_name: 'Bug', foreign_key: 'developer_id', dependent: :nullify

  after_create :assign_default_role

  private

  def assign_default_role
    if user_type.present?
      add_role(user_type.to_sym)
    end
  end
end
