require 'rails_helper'

RSpec.describe 'Deleting a Project Submission' do
  let(:user) { create(:user) }
  let(:lesson) { create(:lesson, :project) }

  before do
    sign_in(user)
    visit lesson_path(lesson)
    Pages::ProjectSubmissions::Form.new.open.fill_in.submit
  end

  it 'removes a submission' do
    users_submission = first(:test_id, 'submission-item')

    within(:test_id, 'submissions-list') do
      expect(page).to have_content(user.username)
    end

    within(users_submission) do
      find(:test_id, 'submission-action-menu-btn').click

      page.accept_confirm do
        find(:test_id, 'delete-submission').click
      end
    end

    expect(page).to have_content('Add solution')

    within(:test_id, 'submissions-list') do
      expect(page).not_to have_content(user.username)
    end
  end
end
