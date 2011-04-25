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
      And I should see 0 demomen signed up
      And I should see 0 medics signed up
      And I should see 0 captains signed up
      
  Scenario: Remove signup
    Given an empty pug
    When I sign up as scout, soldier
      And I remove my signup
    Then I should see 0 players signed up
      And I should see 0 scouts signed up
      And I should see 0 soldiers signed up
      And I should see 0 demomen signed up
      And I should see 0 medics signed up
      And I should see 0 captains signed up
      
  Scenario: Overwriting signup
    Given an empty pug
    When I sign up as scout, soldier
      And I sign up as scout, demoman
    Then I should see 1 player signed up
      And I should see 1 scout signed up
      And I should see 0 soldiers signed up
      And I should see 1 demoman signed up
      And I should see 0 medics signed up
      And I should see 0 captains signed up
   
  Scenario: Multiple signups
    Given an empty pug
    When I sign up as scout, soldier
      And pingu signs up as scout, medic
    Then I should see 2 players signed up
      And I should see 2 scouts signed up
      And I should see 1 soldier signed up
      And I should see 0 demomen signed up
      And I should see 1 medic signed up
      And I should see 0 captains signed up
      
  Scenario: Empty pug
    Given an empty pug
    Then I should see 0 players signed up
      And I should see 0 scouts signed up
      And I should see 0 soldiers signed up
      And I should see 0 demomen signed up
      And I should see 0 medics signed up
      And I should see 0 captains signed up
      
  Scenario: Unrelated remove
    Given an empty pug
    When I sign up as scout, soldier
      And pingu removes his signup
    Then I should see 1 players signed up
      And I should see 1 scouts signed up
      And I should see 1 soldiers signed up
      And I should see 0 demomen signed up
      And I should see 0 medics signed up
      And I should see 0 captains signed up
