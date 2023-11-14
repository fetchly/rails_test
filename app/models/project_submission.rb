class ProjectSubmission < ApplicationRecord
  include Discard::Model
  include Likeable

  before_update do
    self.discard_at = nil if repo_url_changed? || live_preview_url_changed?
  end

  belongs_to :user
  belongs_to :lesson

  validates :repo_url, url: true
  validates :live_preview_url, url: true, allow_blank: true
  validate :live_preview_allowed
  validates :repo_url, presence: { message: 'Required' }
  validates :user_id, uniqueness: { scope: :lesson_id, message: 'You have already submitted a project for this lesson' }

  scope :only_public, -> { where(is_public: true, discarded_at: nil) }
  scope :not_removed_by_admin, -> { where(discarded_at: nil) }
  scope :discardable, -> { not_removed_by_admin.where(discard_at: ..Time.zone.now) }

  private

  def live_preview_allowed
    return if live_preview_url.blank?

    unless lesson && lesson.previewable?
      errors.add(:live_preview_url, 'Live preview is not allowed for this project')
    end
  end
end
