Feature: Signups
  In order to play a pug
  As a player
  I want to signup as classes
  
  Scenario: Add signup
    Given an empty pug
    When I sign up as scout, soldier
    Then I should see 1 player signed up
      And I should see 1 scout signed up
      And I should see 1 soldier signed up
      And I should see 0 demos signed up
      And I should see 0 medics signed up
      And I should see 0 captains signed up
      
  Scenario: Remove signup
    Given an empty pug
    When I sign up as scout, soldier
      And I remove my signup
    Then I should see 0 players signed up
      And I should see 0 scouts signed up
      And I should see 0 soldiers signed up
      And I should see 0 demos signed up
      And I should see 0 medics signed up
      And I should see 0 captains signed up
      
  Scenario: Multiple add signups
    Given an empty pug
    When I sign up as scout, soldier
      And I sign up as scout, demo
    Then I should see 1 player signed up
      And I should see 1 scout signed up
      And I should see 0 soldiers signed up
      And I should see 1 demo signed up
      And I should see 0 medics signed up
      And I should see 0 captains signed up
   
  Scenario: Multiple remove signups
    Given an empty pug
    When I sign up as scout, soldier
      And I remove my signup
      And I remove my signup
    Then I should see 0 players signed up
      And I should see 0 scouts signed up
      And I should see 0 soldiers signed up
      And I should see 0 demos signed up
      And I should see 0 medics signed up
      And I should see 0 captains signed up
