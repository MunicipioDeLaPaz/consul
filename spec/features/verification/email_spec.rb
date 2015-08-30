require 'rails_helper'

feature 'Verify email' do

  scenario 'Verify' do
    user = create(:user,
                  residence_verified_at: Time.now,
                  document_number:       '12345678Z',
                  document_type:         'dni')

    verified_user = create(:verified_user,
                           document_number: '12345678Z',
                           document_type:   'dni',
                           email:           'rock@example.com')

    login_as(user)

    visit verified_user_path

    within("#verified_user_#{verified_user.id}_email") do
      expect(page).to have_content 'roc*@example.com'
      click_button "Send"
    end

    expect(page).to have_content 'We have send you a confirmation email to your email account: rock@example.com'

    sent_token = /.*email_verification_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit email_path(email_verification_token: sent_token)

    expect(page).to have_content "You are now a verified user"

    expect(page).to_not have_link "Verify my account"
    expect(page).to have_content "You are a level 3 user"
  end

  scenario "Errors on token verification" do
    user = create(:user, residence_verified_at: Time.now)

    login_as(user)
    visit email_path(email_verification_token: "1234")

    expect(page).to have_content "Incorrect verification code"
  end

  scenario "Errors on sending confirmation email" do
    user = create(:user,
                  residence_verified_at: Time.now,
                  document_number:       '12345678Z',
                  document_type:         'dni')

    verified_user = create(:verified_user,
                           document_number: '12345678Z',
                           document_type:   'dni',
                           email:           'rock@example.com')

    login_as(user)

    visit verified_user_path

    verified_user.destroy
    click_button "Send"

    expect(page).to have_content "There was a problem sending you an email to your account"
  end
end