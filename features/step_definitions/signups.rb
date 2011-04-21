require 'tf2pug/bot/fake'
require 'tf2pug/logic/signup'
require 'tf2pug/model/pug'

@myself = UserFake.new(:name => "pingu")

Given /^an empty pug$/ do
  Pug.waiting.clear_signups
end

When /^I sign up as (.)+$/ do |tfclasses|
  SignupLogic.add_signup(@myself, tfclasses.split(", "))
end

When /^I remove my signup$/ do
  SignupLogic.remove_signup(@myself)
end

Then /^I should see (\d+) (scouts?|soldiers?|demos?|medics?|captains?|players?) signed up$/ do |count, clss|
  pug = Pug.waiting
  clss = clss.chomp('s') # remove the s
  
  if clss == "player"
    pug.count_signups.should == count
  else
    tfclass = Tfclass.first(:name => clss)
    pug.tfclass_signups(tfclass).count.should == count
  end
end
