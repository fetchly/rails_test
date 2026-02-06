class DiscardProjectSubmissionJob
  include Sidekiq::Worker
  sidekiq_options retry: 1, dead: false

  def perform
    submissions = ProjectSubmission.discardable.to_a
    submissions.each do |submission|
      submission.discard!
      Notifications::FlagNotification.new(submission).notify_discord if submission.flagged?
    end
  end
end
