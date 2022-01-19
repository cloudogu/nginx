Feature: Searches for the custom HTML page

    Scenario: opening the warp menu and looking for the link of the custom HTML page
      When the user opens the always existing cas ui
      Then the user opens the warp menu
      Then the user checks link corresponding to the custom page

    Scenario: entering the ressource URL into browser and opening the static custom HTML page
      When the user requests the static custom HTML page
      Then a static HTML custom page gets displayed
