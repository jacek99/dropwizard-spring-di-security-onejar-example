@country
Feature: Country REST Service

  @country_get
  Scenario: Query all
    # should get empty response
    When "read:test" sends GET "/myapp/services/rest/country"
    Then I expect HTTP code 200
    And I expect JSON equivalent to
    """
    []
    """

  @country_get_error
  Scenario Outline: Query error handling
    When "<user>:test" sends <method> "/myapp/services/rest/country/WRONG_ID"
    Then I expect HTTP code 404

  Examples:
    | method  | user  |
    | GET     | read  |
    | PATCH   | admin |
    | DELETE  | admin |


  @country_add
  Scenario: Add one
    # add and return JSON as part of the payload
    When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland"
    Then I expect HTTP code 201
    And I expect JSON equivalent to
    """
      {
          "countryCode": "PL",
          "name": "Poland"
      }
    """
    And I expect HTTP header "location" equals "/country/PL"
    # verify it got added
    When "read:test" sends GET "/myapp/services/rest/country"
    Then I expect HTTP code 200
    And I expect JSON equivalent to
    """
      [
          {
              "countryCode": "PL",
              "name": "Poland"
          }
      ]
    """

  @country_add_error
  Scenario Outline: Add error handling
    When "admin:test" sends POST "/myapp/services/rest/country" with "<params>"
    Then I expect HTTP code <code>
    And I expect JSON equivalent to
    """
      {
          "entityName": "Country",
          "error": "<error>",
          "field": "<field>"
      }
    """

  Examples:
    | params                                              | code  | field           | error                           |
    # test missing values
    | name=XX                                             | 400   | countryCode     | may not be null                 |
    | countryCode=PL                                      | 400   | name            | may not be null                 |
    # test invalid country codes
    | countryCode=1&name=Poland                           | 400   | countryCode     | size must be between 2 and 2    |
    | countryCode=123&name=Poland                         | 400   | countryCode     | size must be between 2 and 2    |
    # test invalid name
    | countryCode=PL&name=S                               | 400   | name            | size must be between 3 and 50    |

  @country_dup
  Scenario: Disallow duplicates
    # add
    When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland"
    Then I expect HTTP code 201
    # try add a second one - should throw a 409 Conflict
    When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Polska"
    Then I expect HTTP code 409
    And I expect JSON equivalent to
    """
      {
          "entityName": "Country",
          "error": "A data conflict has occurred. An entity of type Country identified by countryCode=PL conflicts with an existing entity",
          "field": "countryCode",
          "value": "PL"
      }
    """
    # verify only 1 exists
    When "read:test" sends GET "/myapp/services/rest/country"
    Then I expect HTTP code 200
    And I expect JSON equivalent to
    """
      [
          {
              "countryCode": "PL",
              "name": "Poland"
          }
      ]
    """

  @country_update
  Scenario Outline: Update
    # add
    When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland"
    Then I expect HTTP code 201
    # update it
    When "admin:test" sends PATCH "/myapp/services/rest/country/PL" with "<params>"
    Then I expect HTTP code 200
    # verify
    When "read:test" sends GET "/myapp/services/rest/country/PL"
    Then I expect HTTP code 200
    And I expect JSON equivalent to
    """
    <content>
    """

  Examples:
    | params                                    | content                                                                 |
    | name=Polska                               | {"countryCode": "PL","name": "Polska"}                 |

  @country_update_error
  Scenario Outline: Update error handling
    # add
    When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland"
    Then I expect HTTP code 201
    # update
    When "admin:test" sends PATCH "/myapp/services/rest/country/PL" with "<params>"
    Then I expect HTTP code <code>
    And I expect JSON equivalent to
    """
      {
          "entityName": "Country",
          "error": "<error>",
          "field": "<field>"
      }
    """

  Examples:
    | params                                              | code  | field           | error                           |
     # test invalid name
    | name=S                                              | 400   | name           | size must be between 3 and 50    |

  @country_delete
  Scenario: Delete single
    # add 2
    When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland"
    Then I expect HTTP code 201
    When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=DE&name=Germany"
    Then I expect HTTP code 201
    # delete & validate
    When "admin:test" sends DELETE "/myapp/services/rest/country/PL"
    Then I expect HTTP code 200
    When "read:test" sends GET "/myapp/services/rest/country"
    Then I expect HTTP code 200
    And I expect JSON equivalent to
    """
    [
        {
            "countryCode": "DE",
            "name": "Germany"
        }
    ]
    """

  @country_security
  Scenario: Security validation (401 = not authenticated, 403 = not authorized)
    # add one
    When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland"
    Then I expect HTTP code 201
    # read user has wrong password
    When "read:wrong_test" sends GET "/myapp/services/rest/country"
    Then I expect HTTP code 401
    When "read:wrong_test" sends GET "/myapp/services/rest/country/PL"
    Then I expect HTTP code 401
    # read user cannot POST
    When "read:test" sends POST "/myapp/services/rest/country" with "countryCode=US&name=USA"
    Then I expect HTTP code 403
    # write has wrong password
    When "admin:wrong_test" sends POST "/myapp/services/rest/country" with "countryCode=US&name=USA"
    Then I expect HTTP code 401
    When "admin:wrong_test" sends PATCH "/myapp/services/rest/country/PL" with "name=Polska"
    Then I expect HTTP code 401
    # user does not have access to POST or PATCH
    When "read:test" sends POST "/myapp/services/rest/country" with "countryCode=US&name=USA"
    Then I expect HTTP code 403
    When "read:test" sends PATCH "/myapp/services/rest/country/PL" with "name=Polska"
    Then I expect HTTP code 403
    # user does not have access to DELETE
    When "read:test" sends DELETE "/myapp/services/rest/country/PL"
    Then I expect HTTP code 403
    # DELETE has wrong password
    When "admin:wrong_test" sends DELETE "/myapp/services/rest/country/PL"
    Then I expect HTTP code 401


