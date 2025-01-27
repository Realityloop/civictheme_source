@p1 @civictheme @content_type @civictheme_alert
Feature: CivicTheme Alert content type render

  Background:
    Given civictheme_alert content:
      | nid    | title                                        | status | field_c_n_alert_type | field_c_n_alert_page_visibility | field_c_n_body                              | field_c_n_date_range:value      | field_c_n_date_range:end_value   |
      | 999991 | [TEST] Test alert title Homepage only        | 1      | information          | /                               | [TEST] Test alert body Homepage only        | [relative:-1 day#Y-m-d\TH:i:s]  | [relative:+10 days#Y-m-d\TH:i:s] |
      | 999992 | [TEST] Test alert title all pages            | 1      | error                |                                 | [TEST] Test alert body all pages            | [relative:-1 day#Y-m-d\TH:i:s]  | [relative:+10 days#Y-m-d\TH:i:s] |
      | 999993 | [TEST] Test dismissing alert title all pages | 1      | error                |                                 | [TEST] Test dismissing alert body all pages | [relative:-1 day#Y-m-d\TH:i:s]  | [relative:+10 days#Y-m-d\TH:i:s] |
      | 999994 | [TEST] Test alert title all pages future     | 1      | error                |                                 | [TEST] Test alert body all pages future     | [relative:+2 days#Y-m-d\TH:i:s] | [relative:+10 days#Y-m-d\TH:i:s] |

    Given civictheme_page content:
      | title                       | status |
      | [TEST] Test alerts on pages | 1      |

  @api @javascript
  Scenario: Alerts can be viewed on homepage
    Given I am an anonymous user
    And I go to the homepage
    And wait 5 second
    And I wait for AJAX to finish
    And I should see the text "[TEST] Test alert title Homepage only"
    And I should see the text "[TEST] Test alert body Homepage only"
    And I should see the text "[TEST] Test alert title all pages"
    And I should see the text "[TEST] Test alert body all pages"
    And I should see the text "[TEST] Test dismissing alert title all pages"
    And I should see the text "[TEST] Test dismissing alert body all pages"

  @api @javascript
  Scenario: Alerts should follow the visibility settings
    Given I am an anonymous user
    When I visit "civictheme_page" "[TEST] Test alerts on pages"
    And wait 5 second
    And I wait for AJAX to finish
    Then I should not see the text "[TEST] Test alert body Homepage only"
    And I should see the text "[TEST] Test alert body all pages"
    And I should see the text "[TEST] Test dismissing alert body all pages"

  @api @javascript
  Scenario: Alerts should be dismissed and not shown in the same session
    Given I am an anonymous user
    And I visit "civictheme_page" "[TEST] Test alerts on pages"
    And wait 5 second
    And I wait for AJAX to finish
    And I should not see the text "[TEST] Test alert body Homepage only"
    And I should see the text "[TEST] Test alert body all pages"
    And I should see the text "[TEST] Test dismissing alert body all pages"
    When I press "dismiss-alert-999993"
    Then I should not see the text "[TEST] Test alert body Homepage only"
    And I should see the text "[TEST] Test alert body all pages"
    And I should not see the text "[TEST] Test dismissing alert body all pages"
    # Revisit same page - the banner should remain dismissed.
    When I visit "civictheme_page" "[TEST] Test alerts on pages"
    And wait 3 seconds
    Then I should not see the text "[TEST] Test alert body Homepage only"
    And I should see the text "[TEST] Test alert body all pages"
    And I should not see the text "[TEST] Test dismissing alert body all pages"
    # New session - the alert should be visible.
    Given I am an anonymous user
    When I visit "civictheme_page" "[TEST] Test alerts on pages"
    And wait 5 second
    And I wait for AJAX to finish
    Then I should not see the text "[TEST] Test alert body Homepage only"
    And I should see the text "[TEST] Test alert body all pages"
    And I should see the text "[TEST] Test dismissing alert body all pages"

  @api @javascript
  Scenario: Alerts should be dismissed and not shown in same session for logged in user
    Given I am logged in as a user with the "Site Administrator" role
    When I visit "civictheme_page" "[TEST] Test alerts on pages"
    And wait 5 second
    And I wait for AJAX to finish
    Then I should see the text "[TEST] Test dismissing alert body all pages"
    And I should see the text "[TEST] Test alert body all pages"
    And I press "dismiss-alert-999993"
    And I should not see the text "[TEST] Test dismissing alert body all pages"
    # Revisit same page - the alert should remain dismissed.
    And I visit "civictheme_page" "[TEST] Test alerts on pages"
    And I should not see the text "[TEST] Test dismissing alert body all pages"
    # New session - the alert should not be visible for logged in user.
    Given I am logged in as a user with the "Site Administrator" role
    When I visit "civictheme_page" "[TEST] Test alerts on pages"
    And wait 5 second
    And I wait for AJAX to finish
    Then I should see the text "[TEST] Test alert body all pages"
    And I should not see the text "[TEST] Test dismissing alert body all pages"

  @api @javascript
  Scenario: Alerts should be dismissed and shown if their content was updated
    Given I am logged in as a user with the "Site Administrator" role
    When I visit "civictheme_page" "[TEST] Test alerts on pages"
    And wait 5 second
    And I wait for AJAX to finish
    Then I should see the text "[TEST] Test dismissing alert body all pages"
    And I should see the text "[TEST] Test alert body all pages"
    And I press "dismiss-alert-999993"
    And I should not see the text "[TEST] Test dismissing alert body all pages"
    # Revisit same page - the alert should remain dismissed.
    And I visit "civictheme_page" "[TEST] Test alerts on pages"
    And I should not see the text "[TEST] Test dismissing alert body all pages"
    # Update the content.
    When I edit civictheme_alert "[TEST] Test dismissing alert title all pages"
    And wait 3 second
    And I fill in WYSIWYG "Message" with "[TEST] Test dismissing alert body all pages updated"
    And I press "Save"
    When I visit "civictheme_page" "[TEST] Test alerts on pages"
    And wait 5 second
    And I wait for AJAX to finish
    Then I should see the text "[TEST] Test alert body all pages"
    And I should see the text "[TEST] Test dismissing alert body all pages updated"

  @api @javascript
  Scenario: Alerts should not be shown if the date range is not today
    Given I am logged in as a user with the "Site Administrator" role
    When I visit "civictheme_page" "[TEST] Test alerts on pages"
    And wait 5 second
    And I wait for AJAX to finish
    Then I should see the text "[TEST] Test alert body all pages"
    And I should not see the text "[TEST] Test alert body all pages future"
