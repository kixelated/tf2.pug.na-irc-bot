require 'tf2pug/model/pug'

def myself
  User.first_or_create(:nick => "pingu")
end

Given /^an empty pug$/ do
  (Pug.waiting || Pug.create_random).signup_clear
end

When /^I sign up as (.+)$/ do |tfclasses|
  puts tfclasses.split(", ")
  temp = Tfclass.all(:name => tfclasses.split(", "))
  Pug.waiting.signup_add(myself, temp)
end

When /^I remove my signup$/ do
  Pug.waiting.signup_remove(myself)
end

Then /^I should see (\d+) (scouts?|soldiers?|demos?|medics?|captains?|players?) signed up$/ do |count, clss|
  clss = clss.chomp('s') # remove the s

  if clss == "player"
    Pug.waiting.signups.count.should == count.to_i
  else
    tfclass = Tfclass.first(:name => clss)
    Pug.waiting.signup_class(tfclass).size.should == count.to_i
  end
end
