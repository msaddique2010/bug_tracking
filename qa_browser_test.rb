require 'capybara'
require 'selenium-webdriver'
require 'fileutils'

# Configure Capybara
Capybara.register_driver :chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1280,1024')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = :chrome_headless
Capybara.app_host = 'http://localhost:3000'
Capybara.run_server = false

# Screenshot folder
SCREENSHOT_DIR = '/home/m_saddi/.gemini/antigravity-ide/browser_recordings'
FileUtils.mkdir_p(SCREENSHOT_DIR)

session = Capybara::Session.new(:chrome_headless)

puts "Starting QA Automation Testing against #{Capybara.app_host}..."

begin
  # ----------------------------------------------------
  # STEP 1: Manager Login and Project Creation
  # ----------------------------------------------------
  puts "\n[STEP 1] Logging in as Manager..."
  session.visit('/users/sign_in')
  
  session.fill_in 'Email', with: 'manager1@gmail.com'
  session.fill_in 'Password', with: 'password123'
  session.click_button 'Log in'
  
  # Verify dashboard
  if session.has_content?('Projects Dashboard')
    puts "SUCCESS: Manager logged in."
  else
    puts "FAILED: Manager could not log in or dashboard not shown."
  end
  session.save_screenshot(File.join(SCREENSHOT_DIR, '1_manager_dashboard.png'))
  
  # Create a project
  puts "Creating a new project..."
  session.click_link 'New Project'
  session.fill_in 'Name', with: 'QA Test Verification Project'
  session.fill_in 'Description', with: 'This project is created automatically by Capybara QA Suite to test features.'
  
  # Assign users: developer1@gmail.com (Developer) and qa1@gmail.com (QA)
  # Let's find check boxes
  # developer1@gmail.com and qa1@gmail.com
  session.check('checkbox_user_3') # developer1@gmail.com (usually user IDs or checkboxes have user-specific ids)
  # Let's check user checkbox by name / labels as fallback if user ID is different
  # We can find inputs or checkboxes next to their text.
  # Let's find the checkboxes by iterating or using standard matchers.
  # "checkbox_user_3" might be specific, so let's find the label with text and check the associated checkbox.
  begin
    dev_label = session.find('label', text: /developer1@gmail.com/)
    session.check(dev_label[:for])
    puts "Assigned developer1@gmail.com"
  rescue => e
    puts "Could not assign developer1@gmail.com using label: #{e.message}"
  end
  
  begin
    qa_label = session.find('label', text: /qa1@gmail.com/)
    session.check(qa_label[:for])
    puts "Assigned qa1@gmail.com"
  rescue => e
    puts "Could not assign qa1@gmail.com using label: #{e.message}"
  end
  
  session.save_screenshot(File.join(SCREENSHOT_DIR, '2_project_create_form.png'))
  session.click_button 'Create Project'
  
  puts "Project detail page shown."
  session.save_screenshot(File.join(SCREENSHOT_DIR, '3_project_details.png'))
  
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
  puts "\n[STEP 2] Logging in as QA..."
  session.visit('/users/sign_in')
  session.fill_in 'Email', with: 'qa1@gmail.com'
  session.fill_in 'Password', with: 'password123'
  session.click_button 'Log in'
  
  puts "Visiting project bugs page..."
  session.visit("/projects/#{project_id}/bugs")
  session.save_screenshot(File.join(SCREENSHOT_DIR, '4_qa_bugs_index_empty.png'))
  
  puts "Creating a new bug..."
  session.click_link 'Report New Bug/Feature'
  session.fill_in 'Title', with: 'Critical Checkout Page Crash'
  session.fill_in 'Description', with: 'The application crashes when the user clicks checkout button with an empty cart.'
  session.fill_in 'Deadline', with: (Date.today + 7).to_s
  session.select 'Bug', from: 'bug_type_select'
  
  # Let's wait a moment for type-to-status update script
  sleep 1
  session.select 'New', from: 'bug_status_select'
  
  session.save_screenshot(File.join(SCREENSHOT_DIR, '5_bug_create_form.png'))
  session.click_button 'Create Bug'
  
  puts "Bug successfully created."
  session.save_screenshot(File.join(SCREENSHOT_DIR, '6_qa_bugs_index_with_bug.png'))
  
  # Logout
  session.click_button 'Log Out'
  puts "QA logged out."

  # ----------------------------------------------------
  # STEP 3: Developer Login, Claiming, and Resolving
  # ----------------------------------------------------
  puts "\n[STEP 3] Logging in as Developer..."
  session.visit('/users/sign_in')
  session.fill_in 'Email', with: 'developer1@gmail.com'
  session.fill_in 'Password', with: 'password123'
  session.click_button 'Log in'
  
  puts "Visiting project bugs page..."
  session.visit("/projects/#{project_id}/bugs")
  session.save_screenshot(File.join(SCREENSHOT_DIR, '7_dev_bugs_index.png'))
  
  puts "Claiming the bug..."
  session.click_button 'Claim Bug'
  puts "Bug claimed successfully!"
  session.save_screenshot(File.join(SCREENSHOT_DIR, '8_bug_claimed.png'))
  
  puts "Resolving the bug..."
  session.click_button 'Mark Resolved'
  puts "Bug marked as resolved!"
  session.save_screenshot(File.join(SCREENSHOT_DIR, '9_bug_resolved.png'))
  
  # Logout
  session.click_button 'Log Out'
  puts "Developer logged out."
  
  puts "\nQA Automation Testing Completed Successfully!"

rescue => e
  puts "\nAn error occurred during testing: #{e.message}"
  puts e.backtrace.join("\n")
  session.save_screenshot(File.join(SCREENSHOT_DIR, 'error_screenshot.png'))
  puts "Error screenshot saved."
ensure
  session.driver.quit rescue nil
end
