class Bug < ApplicationRecord
  validates :title, uniqueness: { scope: :project_id }
  validate :correct_image_type
  validates_presence_of :title, :status, :bug_type
  has_one_attached :image
  default_scope { order(created_at: :desc) }
  belongs_to :project
  belongs_to :user

# Source - https://stackoverflow.com/a/57508895
# Posted by awsmketchup, modified by community. See post 'Timeline' for change history
# Retrieved 2026-02-15, License - CC BY-SA 4.0

  private

  def correct_image_type
    valid_formats = %w(image/png image/gif)

    if image.attached? && !image.content_type.in?(valid_formats)
      image.purge
      errors.add(:image, "Must be a PNG or GIF")
    end
  end
end
