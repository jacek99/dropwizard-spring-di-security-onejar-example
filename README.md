Dropwizard Spring DI/Security & OneJar Example
==============================================

Example showing how to integrate Dropwizard, Spring DI, Spring Security and OneJar together.

It also shows how to perform integration testing of a REST application using an external
BDD tool, like Python behave:

https://github.com/behave/behave

This application was prepared for a Houston JUG presentation:
https://github.com/jacek99/dropwizard-spring-di-security-onejar-example/raw/master/Dropwizard_Spring.pdf

**Note**

This application uses Lombok:
http://projectlombok.org/

Please make sure you have the appropriate Lombok plugin installed in your IDE.


Gradle tasks
============

gradle idea
-----------

Regenerate IDEA IntelliJ bindings

gradle eclipse
--------------

Regenerate Eclipse bindings

gradle run
----------

Runs the app *main()* method

gradle oneJar
-------------

Compiles the entire app together with its dependencies into one single super-JAR, using the Gradle OneJar plugin

gradle runOneJar
----------------

Compiles and runs the OneJar version of the app

gradle bdd
----------

Runs the OneJar on a separate thread and executes the entire BDD test suite against the running application.


Integration testing with BDDs
=============================

Mock frameworks are the false prophets of Java application testing.

Your only surefire way to test your logic is to fire requests at your fully running app and verify its behaviour and responses.
Cucumber-style BDDs are the best and most productive way to accomplish this task IMHO:

http://cukes.info/

In this example we use the Python Behave BDD library:

https://github.com/behave/behave

To get it fully running and installed do the following:

**Ubuntu / Debian**

    sudo apt-get install python-setuptools
    sudo easy_install pip
    sudo pip install behave nose httplib2 pyyaml

**Fedora / CentOS**

    sudo yum install python-setuptools
    sudo easy_install pip
    sudo pip install behave nose httplib2 pyyaml

**Windows**

Install the Windows version of Python setuptools:

https://pypi.python.org/pypi/setuptools#windows

The rest is the same afterwards:

     easy_install pip
     pip install behave nose httplib2 pyyaml

Running BDDs manually
=====================

Run the app from your IDE.
Go to a terminal and do

	cd src/test/resources/bdd
	behave

and you should see a human-readable BDD execute:

    @country
    Feature: Country REST Service # features/country_rest.feature:2

      @country_get
      Scenario: Query all                                         # features/country_rest.feature:5
        When "read:test" sends GET "/myapp/services/rest/country" # features/steps/steps.py:93
        Then I expect HTTP code 200                               # features/steps/steps.py:109
        And I expect JSON equivalent to                           # features/steps/steps.py:114
          """
          []
          """

      @country_get_error
      Scenario Outline: Query error handling                               # features/country_rest.feature:15
        When "read:test" sends GET "/myapp/services/rest/country/WRONG_ID" # features/steps/steps.py:93
        Then I expect HTTP code 404                                        # features/steps/steps.py:109

      @country_get_error
      Scenario Outline: Query error handling                                  # features/country_rest.feature:15
        When "admin:test" sends PATCH "/myapp/services/rest/country/WRONG_ID" # features/steps/steps.py:93
        Then I expect HTTP code 404                                           # features/steps/steps.py:109

      @country_get_error
      Scenario Outline: Query error handling                                   # features/country_rest.feature:15
        When "admin:test" sends DELETE "/myapp/services/rest/country/WRONG_ID" # features/steps/steps.py:93
        Then I expect HTTP code 404                                            # features/steps/steps.py:109

      @country_add
      Scenario: Add one                                                                               # features/country_rest.feature:27
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland" # features/steps/steps.py:42
        Then I expect HTTP code 201                                                                   # features/steps/steps.py:109
        And I expect JSON equivalent to                                                               # features/steps/steps.py:114
          """
            {
                "countryCode": "PL",
                "name": "Poland"
            }
          """
        And I expect HTTP header "location" equals "/country/PL"                                      # features/steps/steps.py:140
        When "read:test" sends GET "/myapp/services/rest/country"                                     # features/steps/steps.py:93
        Then I expect HTTP code 200                                                                   # features/steps/steps.py:109
        And I expect JSON equivalent to                                                               # features/steps/steps.py:114
          """
            [
                {
                    "countryCode": "PL",
                    "name": "Poland"
                }
            ]
          """

      @country_add_error
      Scenario Outline: Add error handling                                         # features/country_rest.feature:53
        When "admin:test" sends POST "/myapp/services/rest/country" with "name=XX" # features/steps/steps.py:42
        Then I expect HTTP code 400                                                # features/steps/steps.py:109
        And I expect JSON equivalent to                                            # features/steps/steps.py:114
          """
            {
                "entityName": "Country",
                "error": "may not be null",
                "field": "countryCode"
            }
          """

      @country_add_error
      Scenario Outline: Add error handling                                                # features/country_rest.feature:53
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL" # features/steps/steps.py:42
        Then I expect HTTP code 400                                                       # features/steps/steps.py:109
        And I expect JSON equivalent to                                                   # features/steps/steps.py:114
          """
            {
                "entityName": "Country",
                "error": "may not be null",
                "field": "name"
            }
          """

      @country_add_error
      Scenario Outline: Add error handling                                                           # features/country_rest.feature:53
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=1&name=Poland" # features/steps/steps.py:42
        Then I expect HTTP code 400                                                                  # features/steps/steps.py:109
        And I expect JSON equivalent to                                                              # features/steps/steps.py:114
          """
            {
                "entityName": "Country",
                "error": "size must be between 2 and 2",
                "field": "countryCode"
            }
          """

      @country_add_error
      Scenario Outline: Add error handling                                                             # features/country_rest.feature:53
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=123&name=Poland" # features/steps/steps.py:42
        Then I expect HTTP code 400                                                                    # features/steps/steps.py:109
        And I expect JSON equivalent to                                                                # features/steps/steps.py:114
          """
            {
                "entityName": "Country",
                "error": "size must be between 2 and 2",
                "field": "countryCode"
            }
          """

      @country_add_error
      Scenario Outline: Add error handling                                                       # features/country_rest.feature:53
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=S" # features/steps/steps.py:42
        Then I expect HTTP code 400                                                              # features/steps/steps.py:109
        And I expect JSON equivalent to                                                          # features/steps/steps.py:114
          """
            {
                "entityName": "Country",
                "error": "size must be between 3 and 50",
                "field": "name"
            }
          """

      @country_dup
      Scenario: Disallow duplicates                                                                   # features/country_rest.feature:77
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland" # features/steps/steps.py:42
        Then I expect HTTP code 201                                                                   # features/steps/steps.py:109
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Polska" # features/steps/steps.py:42
        Then I expect HTTP code 409                                                                   # features/steps/steps.py:109
        And I expect JSON equivalent to                                                               # features/steps/steps.py:114
          """
            {
                "entityName": "Country",
                "error": "A data conflict has occurred. An entity of type Country identified by countryCode=PL conflicts with an existing entity",
                "field": "countryCode",
                "value": "PL"
            }
          """
        When "read:test" sends GET "/myapp/services/rest/country"                                     # features/steps/steps.py:93
        Then I expect HTTP code 200                                                                   # features/steps/steps.py:109
        And I expect JSON equivalent to                                                               # features/steps/steps.py:114
          """
            [
                {
                    "countryCode": "PL",
                    "name": "Poland"
                }
            ]
          """

      @country_update
      Scenario Outline: Update                                                                        # features/country_rest.feature:107
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland" # features/steps/steps.py:42
        Then I expect HTTP code 201                                                                   # features/steps/steps.py:109
        When "admin:test" sends PATCH "/myapp/services/rest/country/PL" with "name=Polska"            # features/steps/steps.py:42
        Then I expect HTTP code 200                                                                   # features/steps/steps.py:109
        When "read:test" sends GET "/myapp/services/rest/country/PL"                                  # features/steps/steps.py:93
        Then I expect HTTP code 200                                                                   # features/steps/steps.py:109
        And I expect JSON equivalent to                                                               # features/steps/steps.py:114
          """
          {"countryCode": "PL","name": "Polska"}
          """

      @country_update_error
      Scenario Outline: Update error handling                                                         # features/country_rest.feature:127
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland" # features/steps/steps.py:42
        Then I expect HTTP code 201                                                                   # features/steps/steps.py:109
        When "admin:test" sends PATCH "/myapp/services/rest/country/PL" with "name=S"                 # features/steps/steps.py:42
        Then I expect HTTP code 400                                                                   # features/steps/steps.py:109
        And I expect JSON equivalent to                                                               # features/steps/steps.py:114
          """
            {
                "entityName": "Country",
                "error": "size must be between 3 and 50",
                "field": "name"
            }
          """

      @country_delete
      Scenario: Delete single                                                                          # features/country_rest.feature:149
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland"  # features/steps/steps.py:42
        Then I expect HTTP code 201                                                                    # features/steps/steps.py:109
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=DE&name=Germany" # features/steps/steps.py:42
        Then I expect HTTP code 201                                                                    # features/steps/steps.py:109
        When "admin:test" sends DELETE "/myapp/services/rest/country/PL"                               # features/steps/steps.py:93
        Then I expect HTTP code 200                                                                    # features/steps/steps.py:109
        When "read:test" sends GET "/myapp/services/rest/country"                                      # features/steps/steps.py:93
        Then I expect HTTP code 200                                                                    # features/steps/steps.py:109
        And I expect JSON equivalent to                                                                # features/steps/steps.py:114
          """
          [
              {
                  "countryCode": "DE",
                  "name": "Germany"
              }
          ]
          """

      @country_security
      Scenario: Security validation (401 = not authenticated, 403 = not authorized)                      # features/country_rest.feature:171
        When "admin:test" sends POST "/myapp/services/rest/country" with "countryCode=PL&name=Poland"    # features/steps/steps.py:42
        Then I expect HTTP code 201                                                                      # features/steps/steps.py:109
        When "read:wrong_test" sends GET "/myapp/services/rest/country"                                  # features/steps/steps.py:93
        Then I expect HTTP code 401                                                                      # features/steps/steps.py:109
        When "read:wrong_test" sends GET "/myapp/services/rest/country/PL"                               # features/steps/steps.py:93
        Then I expect HTTP code 401                                                                      # features/steps/steps.py:109
        When "read:test" sends POST "/myapp/services/rest/country" with "countryCode=US&name=USA"        # features/steps/steps.py:42
        Then I expect HTTP code 403                                                                      # features/steps/steps.py:109
        When "admin:wrong_test" sends POST "/myapp/services/rest/country" with "countryCode=US&name=USA" # features/steps/steps.py:42
        Then I expect HTTP code 401                                                                      # features/steps/steps.py:109
        When "admin:wrong_test" sends PATCH "/myapp/services/rest/country/PL" with "name=Polska"         # features/steps/steps.py:42
        Then I expect HTTP code 401                                                                      # features/steps/steps.py:109
        When "read:test" sends POST "/myapp/services/rest/country" with "countryCode=US&name=USA"        # features/steps/steps.py:42
        Then I expect HTTP code 403                                                                      # features/steps/steps.py:109
        When "read:test" sends PATCH "/myapp/services/rest/country/PL" with "name=Polska"                # features/steps/steps.py:42
        Then I expect HTTP code 403                                                                      # features/steps/steps.py:109
        When "read:test" sends DELETE "/myapp/services/rest/country/PL"                                  # features/steps/steps.py:93
        Then I expect HTTP code 403                                                                      # features/steps/steps.py:109
        When "admin:wrong_test" sends DELETE "/myapp/services/rest/country/PL"                           # features/steps/steps.py:93
        Then I expect HTTP code 401                                                                      # features/steps/steps.py:109


    1 feature passed, 0 failed, 0 skipped
    15 scenarios passed, 0 failed, 0 skipped
    80 steps passed, 0 failed, 0 skipped, 0 undefined
    Took 0m0.2s


