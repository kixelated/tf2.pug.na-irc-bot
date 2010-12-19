tf2.pug.na - A TF2 pug bot in Ruby
==================================

Installation
------------

This bot requires Ruby 1.9.0+, which is probably not the installed version on your system. It also requires the sqlite3 gem, which can be installed by:

    gem install sqlite3


Configuration
-------------

Configure your bot by editing cfg/constants.cfg. Please use another channel and nick for testing your bot, so as to reduce the number of conflicts.

Execution
---------

Navigate to the src directory and run the bot with the command:

    ruby -Ilib bot.rb

