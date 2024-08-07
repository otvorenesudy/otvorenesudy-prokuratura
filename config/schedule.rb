# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, 'log/cron.log'

every :day, at: '1:15am' do
  runner 'ExceptionHandler.run { GenproGovSk::Offices.import }'
end

every :day, at: '2:15am' do
  runner 'ExceptionHandler.run { GenproGovSk::Prosecutors.import }'
end

every :sunday, at: '2:30am' do
  runner 'ExceptionHandler.run { GenproGovSk::Declarations.import }'
end

every :sunday, at: '6:00am' do
  runner 'ExceptionHandler.run { GenproGovSk::Declaration.reconcile! }'
end

every :sunday, at: '3:15am' do
  runner 'ExceptionHandler.run { GenproGovSk::Decrees.import }'
end

every :sunday, at: '3:30am' do
  runner 'ExceptionHandler.run { MinvSk::Criminality.import }'
end

every :day, at: '4:15am' do
  runner 'ExceptionHandler.run { GoogleNews.cache_for(::Prosecutor, size: 60) }'
end

every :day, at: '4:15am' do
  runner 'ExceptionHandler.run { GoogleNews.cache_for(::Office, size: 20) }'
end

every :day, at: '4:30am' do
  runner 'ExceptionHandler.run { Prosecutor.remove_excluded_urls_from_news! }'
end

every :day, at: '1:30am' do
  rake '-s sitemap:refresh'
end
