@plugin @plagiarism @plagiarism_turnitinsim @plagiarism_turnitinsim_installed
Feature: Installation succeeds
  In order to use this plugin
  As a user
  I need the installation to work and plagiarism plugins to be enabled

  Scenario:
    Given I log in as "admin"
    And I navigate to "Advanced features" in site administration
    And I set the field "Enable plagiarism plugins" to "1"
    And I press "Save changes"
    And I navigate to "Plugins > Plagiarism > Turnitin Integrity plugin" in site administration
    And I configure Turnitin Integrity credentials
    And I set the following fields to these values:
      | Enable Turnitin Integrity for Assign | 1 |
    And I press "Save changes"
    Then the following should exist in the "plugins-control-panel" table:
      | Plugin name         |
      | plagiarism_turnitin |
