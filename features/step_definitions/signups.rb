require 'tf2pug/model/pug'

Given /^an empty pug$/ do
  (Pug.waiting || Pug.create_random).signup_clear
end

When /^(.+) signs? up as (.+)$/ do |nick, classes|
  user = User.first_or_create(:nick => nick)
  tfclasses = Tfclass.all(:name => classes.split(", "))

  Pug.waiting.signup_add(user, tfclasses)
end

When /^(.+) removes? (?:my|his|her|their) signup$/ do |nick|
  user = User.first_or_create(:nick => nick)
  
  Pug.waiting.signup_remove(user)
end

When /^(.+) replaces (.+)$/ do |nick_new, nick_old|
  user_new = User.first_or_create(:nick => nick_new)
  user_old = User.first_or_create(:nick => nick_old)
  
  Pug.waiting.signup_replace(user_new, user_old)
end

Then /^I should see (\d+) (scouts?|soldiers?|demomen|demoman|medics?|captains?|players?) signed up$/ do |count, clss|
  clss = clss.chomp('s') # remove the s
  clss = "demoman" if clss == "demomen" # demoman doesn't pluralize as easily

  if clss == "player"
    Pug.waiting.signup_users.size.should == count.to_i
  else
    tfclass = Tfclass.first(:name => clss)
    Pug.waiting.signup_classes[tfclass].size.should == count.to_i
  end
end

Then /^(.+) should( not)? be signed up$/ do |nicks, should_not|
  pug = Pug.waiting
  signups = pug.signup_users
  
  nicks.split(", ").each do |nick|
    user = User.first_or_create(:nick => nick)
    if should_not; signups.include?(user).should == false; else; signups.include?(user).should == true; end
  end
end
