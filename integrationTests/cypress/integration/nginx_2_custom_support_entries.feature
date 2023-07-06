Feature: display support entries
  Scenario: opening the warp menu when a etcd-key is set
    Given the warp menu is open
    Then the warp menu category 'Support' contains a link to docs and no link to platform or the about page
