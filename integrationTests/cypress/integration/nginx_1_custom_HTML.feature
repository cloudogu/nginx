Feature: Searches for the custom HTML page

    Scenario: entering the ressource URL into browser and opening the static custom HTML page
      When the user requests the static custom HTML page
      Then a static HTML custom page gets displayed
