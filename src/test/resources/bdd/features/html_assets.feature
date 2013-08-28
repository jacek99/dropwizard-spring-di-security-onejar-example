@html
Feature: HTML assets

  @html_get
  Scenario: Get all HTML resources, including images (was not working with OneJar)
    # should get empty response
    When "read:test" sends GET "/myapp/index.htm"
    Then I expect HTTP code 200
    When "read:test" sends GET "/myapp/logo.png"
    Then I expect HTTP code 200

