tf2.pug.na - A TF2 pug bot in Ruby
==================================

Installation
------------

This bot requires Ruby 1.9.0+, which is probably not the installed version on your system. It also requires the bundler gem, which can be installed with:

    gem install bundler

After installing bundler, navigate to the src directory and execute the command:

    bundle install
    
This will install all of the gems needed for the bot to operate.


Configuration
-------------

Configure your bot by editing cfg/constants.cfg. Please use another channel and nick for testing your bot, so as to reduce the number of conflicts.


Execution
---------

Navigate to the src directory and run the bot with the command:

    ruby -Icinch/lib bot.rb

