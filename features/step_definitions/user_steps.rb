DEFAULT_USER = "testuser"
DEFAULT_PASSWORD = "password"

Given /^I have no users$/ do
  User.delete_all
end

Given /I have an orphan account/ do
  user = Factory.create(:user, :login => 'orphan_account')
  user.activate
end

Given /the following activated users? exists?/ do |table|
  table.hashes.each do |hash|
    user = Factory.create(:user, hash)
    user.activate
  end
end

Given /the following activated tag wranglers? exists?/ do |table|
  table.hashes.each do |hash|
    user = Factory.create(:user, hash)
    user.activate
    user.tag_wrangler = '1'
  end
end

Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  Given "I am logged out"
  user = User.find_by_login(login)
  if user.blank?
    user = Factory.create(:user, {:login => login, :password => password})
    user.activate
  else
    user.password = password
    user.password_confirmation = password
    user.save
  end
  visit login_path
  fill_in "User name", :with => login
  fill_in "Password", :with => password
  check "Remember me"
  click_button "Log in"
  assert UserSession.find
end

Given /^I am logged in as "([^\"]*)"$/ do |login|
  Given %{I am logged in as "#{login}" with password "#{DEFAULT_PASSWORD}"}
end

Given /^I am logged in$/ do
  Given %{I am logged in as "#{DEFAULT_USER}"}
end

When /^I fill in "([^\"]*)"'s temporary password$/ do |login|
  # " '
  user = User.find_by_login(login)
  fill_in "Password", :with => user.activation_code
end


Given /^I am logged in as a random user$/ do
  Given "I am logged out"
  name = "testuser#{User.count + 1}"
  user = Factory.create(:user, :login => name, :password => DEFAULT_PASSWORD)
  user.activate
  visit login_path
  fill_in "User name", :with => name
  fill_in "Password", :with => DEFAULT_PASSWORD
  check "Remember me"
  click_button "Log in"
  assert UserSession.find
end

Given /^I am logged out$/ do
  visit logout_path
  assert !UserSession.find
  visit admin_logout_path
  assert !AdminSession.find
end

Given /^I log out$/ do
  Given %{I follow "log out"}
end

When /^"([^\"]*)" creates the pseud "([^\"]*)"$/ do |username, newpseud|
  visit user_pseuds_path(username)
  click_link("New Pseud")
  fill_in "Name", :with => newpseud
  click_button "Create"
end

Given /^"([^\"]*)" has the pseud "([^\"]*)"$/ do |username, pseud|
  When %{I am logged in as "#{username}"}
  When %{"#{username}" creates the pseud "#{pseud}"}
  When "I am logged out"
end

When /^"([^\"]*)" creates the default pseud "([^\"]*)"$/ do |username, newpseud|
  visit user_pseuds_path(username)
  click_link("New Pseud")
  fill_in "Name", :with => newpseud
  # TODO: this isn't currently working
  check "Make this name default"
  click_button "Create"
end


Given /^"([^\"]*)" deletes their account/ do |username|
  visit user_path(username)
  Given %{I follow "Profile"}
  Given %{I follow "Delete My Account"}
end

Given /^I am a visitor$/ do
  Given %{I am logged out}
end

Then /^I should get the error message for wrong username or password$/ do
  Then %{I should see "The password or user name you entered doesn't match our records. Please try again"}
end
