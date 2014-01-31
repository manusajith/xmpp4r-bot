require 'rubygems'
require 'daemons'

Daemons.run('bot.rb',
  {
    app_name: 'myIMBot',
    monitor: true,
    log_output: true
  }
)
