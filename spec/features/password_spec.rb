require 'spec_helper'

feature "Password recovery" do

  scenario "user requests a new password" do
    visit '/passwords/new'
    expect(page).to have_content("Please enter your email address to recover your password:")
    click_button("Password recovery")
    expect(page).to have_content("An email was just sent to you")
  end


end