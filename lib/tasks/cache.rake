namespace :cache do
  desc 'Clear Rails cache'
  task clear: :environment do
    Rails.cache.clear
    Rake::Task['tmp:clear'].invoke
  end
end
