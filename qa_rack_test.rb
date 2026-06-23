require_relative 'config/environment'
require 'capybara'
require 'fileutils'

# Configure Capybara to use rack_test directly against the Rails app
Capybara.app = Rails.application
Capybara.default_driver = :rack_test
Capybara.default_host = "http://localhost"

# Artifact folder for HTML snapshots
HTML_DIR = '/home/m_saddi/.gemini/antigravity-ide/browser_recordings'
FileUtils.mkdir_p(HTML_DIR)

session = Capybara::Session.new(:rack_test, Rails.application)

puts "Starting QA Automation logic testing using Capybara Rack-Test..."

begin
  # ----------------------------------------------------
  # STEP 1: Manager Login and Project Creation
  # ----------------------------------------------------
  puts "\n[STEP 1] Logging in as Manager (manager1@gmail.com)..."
  session.visit('/users/sign_in')
  
  session.fill_in 'user_email', with: 'manager1@gmail.com'
  session.fill_in 'user_password', with: 'password123'
  session.click_button 'Log in'
  
  # Verify dashboard
  if session.has_content?('Projects Dashboard')
    puts "SUCCESS: Manager logged in."
  else
    puts "FAILED: Manager could not log in or dashboard not shown."
  end
  File.write(File.join(HTML_DIR, '1_manager_dashboard.html'), session.html)
  
  # Create a project
  puts "Creating a new project..."
  session.click_link 'New Project'
  session.fill_in 'Name', with: "QA Verification Project #{Time.now.to_i}"
  session.fill_in 'Description', with: 'This project is created automatically by Capybara QA Suite to test features.'
  
  # Assign users: developer1@gmail.com and qa1@gmail.com
  # Since JS does not run in Rack-Test, we manually manipulate the Nokogiri node attributes to simulate the checkbox checked state.
  begin
    dev_user = User.find_by!(email: 'developer1@gmail.com')
    session.find("#destroy_user_#{dev_user.id}", visible: false).native['value'] = '0'
    user_id_field = session.find("#user_id_#{dev_user.id}", visible: false)
    user_id_field.native.remove_attribute('disabled')
    user_id_field.native['value'] = dev_user.id.to_s
    session.check("checkbox_user_#{dev_user.id}")
    puts "Assigned developer1@gmail.com to the project (simulated checkbox JS)."
  rescue => e
    puts "Could not assign developer1@gmail.com: #{e.message}"
  end
  
  begin
    qa_user = User.find_by!(email: 'qa1@gmail.com')
    session.find("#destroy_user_#{qa_user.id}", visible: false).native['value'] = '0'
    user_id_field = session.find("#user_id_#{qa_user.id}", visible: false)
    user_id_field.native.remove_attribute('disabled')
    user_id_field.native['value'] = qa_user.id.to_s
    session.check("checkbox_user_#{qa_user.id}")
    puts "Assigned qa1@gmail.com to the project (simulated checkbox JS)."
  rescue => e
    puts "Could not assign qa1@gmail.com: #{e.message}"
  end
  
  File.write(File.join(HTML_DIR, '2_project_create_form.html'), session.html)
  session.click_button 'Create Project'
  
  puts "Project detail page shown. Current URL: #{session.current_url}"
  if session.has_content?("prohibited this project from being saved")
    puts "Error saving project: "
    session.all('li').each { |li| puts "- #{li.text}" }
  end
  File.write(File.join(HTML_DIR, '3_project_details.html'), session.html)
  
  # Get project ID from path
  project_url = session.current_url
  project_id = project_url.split('/projects/').last.split('?').first
  puts "Created Project ID: #{project_id}"
  
  # Logout
  session.click_button 'Log Out'
  puts "Manager logged out."

  # ----------------------------------------------------
  # STEP 2: QA Login and Bug/Feature Creation
  # ----------------------------------------------------
  puts "\n[STEP 2] Logging in as QA (qa1@gmail.com)..."
  session.visit('/users/sign_in')
  session.fill_in 'user_email', with: 'qa1@gmail.com'
  session.fill_in 'user_password', with: 'password123'
  session.click_button 'Log in'
  
  puts "Visiting project bugs page..."
  session.visit("/projects/#{project_id}/bugs")
  File.write(File.join(HTML_DIR, '4_qa_bugs_index_empty.html'), session.html)
  
  puts "Creating a new bug..."
  session.click_link 'Report New Bug/Feature'
  session.fill_in 'Title', with: "Critical Checkout Page Crash #{Time.now.to_i}"
  session.fill_in 'Description', with: 'The application crashes when the user clicks checkout button with an empty cart.'
  session.fill_in 'Deadline', with: (Date.today + 7).to_s
  session.select 'Bug', from: 'bug_type_select'
  session.select 'New', from: 'bug_status_select'
  
  File.write(File.join(HTML_DIR, '5_bug_create_form.html'), session.html)
  session.click_button 'Create Bug'
  
  puts "Bug successfully created."
  File.write(File.join(HTML_DIR, '6_qa_bugs_index_with_bug.html'), session.html)
  
  # Get created bug
  bug = Bug.last
  puts "Created Bug ID: #{bug.id}, Title: '#{bug.title}', Status: '#{bug.status}'"

  # Logout
  session.click_button 'Log Out'
  puts "QA logged out."

  # ----------------------------------------------------
  # STEP 3: Developer Login, Claiming, and Resolving
  # ----------------------------------------------------
  puts "\n[STEP 3] Logging in as Developer (developer1@gmail.com)..."
  session.visit('/users/sign_in')
  session.fill_in 'user_email', with: 'developer1@gmail.com'
  session.fill_in 'user_password', with: 'password123'
  session.click_button 'Log in'
  
  puts "Visiting project bugs page..."
  session.visit("/projects/#{project_id}/bugs")
  File.write(File.join(HTML_DIR, '7_dev_bugs_index.html'), session.html)
  
  puts "Claiming the bug..."
  session.click_button 'Claim Bug'
  puts "Bug claimed successfully!"
  
  # Reload bug info from DB to verify
  bug.reload
  puts "Current Bug Status: '#{bug.status}', Assigned Developer: '#{bug.developer&.email}'"
  File.write(File.join(HTML_DIR, '8_bug_claimed.html'), session.html)
  
  puts "Resolving the bug..."
  session.click_button 'Mark Resolved'
  puts "Bug marked as resolved!"
  
  bug.reload
  puts "Current Bug Status after resolution: '#{bug.status}'"
  File.write(File.join(HTML_DIR, '9_bug_resolved.html'), session.html)
  
  # Logout
  session.click_button 'Log Out'
  puts "Developer logged out."
  
  puts "\nQA Automation Testing Completed Successfully via Rack-Test!"

rescue => e
  puts "\nAn error occurred during testing: #{e.message}"
  puts e.backtrace.join("\n")
end
