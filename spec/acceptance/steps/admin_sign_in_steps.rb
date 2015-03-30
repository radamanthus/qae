step "Admin user exists" do
  @admin = FactoryGirl.create(:admin, password: "my98ssdkjv9823kds=2")
end

step "I sign in as admin" do
  visit '/admins/sign_in'
  fill_in 'admin_email', with: @admin.email
  fill_in 'admin_password', with: "my98ssdkjv9823kds=2"
  click_button 'Log in'
end

step "I should see sign out link" do
  expect(page).to have_link('Log out')
end

step "I am admin user" do
  step "Admin user exists"
  step "I sign in as admin"
end
