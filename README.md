tf2.pug.na - A TF2 pug bot in Ruby
==================================

Installation
------------

This bot requires Ruby 1.9.2. Please check your ruby version with the -v flag, as 1.8.7 is the typical installation.

There are a few gems required to run the bot. Navigate to the "gems" directory and run the following command:

    gem install sqlite3 activerecord rcon chronic_duration

The sqlite3 gem is experimental and may break, but you can install sqlite3-ruby gem instead (requires sqlite3 installed on the system).


Configuration
-------------

Configure your bot by editing cfg/constants.cfg. Please use another channel and nick for testing your bot, so as to reduce the number of conflicts.


Execution
---------

Navigate to the src directory and run the bot with the command:

    ruby -Icinch/lib bot.rb

