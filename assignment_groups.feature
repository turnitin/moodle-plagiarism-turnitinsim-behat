@plugin @plagiarism @plagiarism_turnitinsim @plagiarism_turnitinsim_assignment @plagiarism_turnitinsim_assignment_groups
Feature: Group assignment submissions
  In order to allow students to work collaboratively on an assignment
  As a teacher
  I need to group submissions in groups

  Background: Set up the users, course, groups and assignment with plugin enabled
    Given the following "courses" exist:
      | fullname | shortname | category | groupmode |
      | Course 1 | C1        | 0        | 1         |
    And I create a unique moodle user with username "student1"
    And I create a unique moodle user with username "student2"
    And the following "course enrolments" exist:
      | user        | course | role           |
      | student1    | C1     | student        |
      | student2    | C1     | student        |
    And the following "groups" exist:
      | name    | course | idnumber |
      | Group 1 | C1     | G1       |
    # Enable and configure plugin.
    When I log in as "admin"
    And I navigate to "Advanced features" in site administration
    And I set the field "Enable plagiarism plugins" to "1"
    And I press "Save changes"
    And I navigate to "Plugins > Plagiarism > Turnitin Integrity plugin" in site administration
    And I configure Turnitin Integrity credentials
    And I set the following fields to these values:
      | Enable Turnitin Integrity for Assign | 1 |
    And I press "Save changes"
    # Create Assignment.
    And I am on "Course 1" course homepage with editing mode on
    And I add a "Assignment" to section "1" and I fill the form with:
      | Assignment name               | Test assignment name |
      | turnitinenabled               | 1                    |
      | accessoptions[accessstudents] | 1                    |
      | Students submit in groups     | Yes                  |
      | Group mode                    | Separate groups      |
    And I navigate to "Users > Groups" in current page administration
    And I add "student1 student1" user to "Group 1" group members
    And I add "student2 student2" user to "Group 1" group members
    And I am on "Course 1" course homepage
    And I follow "Test assignment name"
    And I navigate to "View all submissions" in current page administration
    And I follow "Test assignment name"
    Then I should see "Grading summary"

  @javascript @_file_upload
  Scenario: Confirm that all students in a group can access the Cloud Viewer even if they didn't submit.
    Given I log out
    # Student submits.
    And I log in as "student1"
    And I am on "Course 1" course homepage
    And I follow "Test assignment name"
    And I press "Add submission"
    And I click on "#turnitinsim_eula_accept" "css_element"
    And I upload "plagiarism/turnitinsim/tests/fixtures/testfile.txt" file to "File submissions" filemanager
    And I press "Save changes"
    Then I should see "Submitted for grading"
    And I should see "Queued"
    And I log out
    # Admin runs scheduled task to send submission to Turnitin.
    And I log in as "admin"
    And I run the scheduled task "plagiarism_turnitinsim\task\send_submissions"
    And I am on "Course 1" course homepage
    And I follow "Test assignment name"
    When I navigate to "View all submissions" in current page administration
    Then "student1 student1" row "File submissions" column of "generaltable" table should contain "Pending"
    And "student2 student2" row "File submissions" column of "generaltable" table should contain "Pending"
    # Admin runs scheduled task to request an originality report.
    And I wait "10" seconds
    And I run the scheduled task "plagiarism_turnitinsim\task\get_reports"
    # Admin runs scheduled task to request originality report score.
    And I wait "20" seconds
    And I run the scheduled task "plagiarism_turnitinsim\task\get_reports"
    And I wait "30" seconds
    And I run the scheduled task "plagiarism_turnitinsim\task\get_reports"
    And I am on "Course 1" course homepage
    And I follow "Test assignment name"
    When I navigate to "View all submissions" in current page administration
    Then "student1 student1" row "File submissions" column of "generaltable" table should contain "%"
    And "student2 student2" row "File submissions" column of "generaltable" table should contain "%"
    # Open the Cloud Viewer as student2.
    And I log out
    And I log in as "student2"
    And I am on "Course 1" course homepage
    And I follow "Test assignment name"
    Then I should see "%"
    And I click on ".or_score" "css_element"
    And I switch to viewer window
    And I click on "Accept" "button"
    Then I should see "testfile.txt"
    And I should see "student1 student1"