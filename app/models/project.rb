class Project < ApplicationRecord
  belongs_to :user
  has_many :bugs, dependent: :destroy
end
