@application_server
Feature: mstest

  Scenario: is installed

    Then the file "mstest.exe" should be found at "%VS110COMNTOOLS%\..\IDE"