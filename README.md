tf2.pug.na - A TF2 pug bot in Ruby
==================================

Installation
------------

This bot requires Ruby 1.9.2. Please check your ruby version with the -v flag, as 1.8.7 is the typical installation.

There are a few gems required to run the bot, and the bundler gem will install and manage these gems for you. Open terminal and run the following command:

    gem install bundler

Once bundler is installed, change to the "src" directory and run the command:

    bundle install


Configuration
-------------

Configure your bot by editing cfg/constants.cfg. Please use another channel and nick for testing your bot, so as to reduce the number of conflicts.


Execution
---------

Navigate to the src directory and run the bot with the command:

    ruby -Icinch/lib bot.rb

