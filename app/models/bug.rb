class Bug < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'
  belongs_to :developer, class_name: 'User', foreign_key: 'developer_id', optional: true

  has_one_attached :image

  default_scope { order(created_at: :desc) }

  validates :title, presence: true, uniqueness: { scope: :project_id }
  validates :status, presence: true
  validates :bug_type, presence: true, inclusion: { in: %w[feature bug] }

  validate :correct_image_type
  validate :status_matches_type

  private

  def correct_image_type
    valid_formats = %w(image/png image/gif)

    if image.attached? && !image.content_type.in?(valid_formats)
      image.purge
      errors.add(:image, "must be a PNG or GIF")
    end
  end

  def status_matches_type
    if bug_type == 'feature'
      unless status.in?(%w[new started completed])
        errors.add(:status, "must be new, started, or completed for a feature")
      end
    elsif bug_type == 'bug'
      unless status.in?(%w[new started resolved])
        errors.add(:status, "must be new, started, or resolved for a bug")
      end
    end
  end
end
