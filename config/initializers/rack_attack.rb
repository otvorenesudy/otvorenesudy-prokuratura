if Rails.env.production?
  Rack::Attack.blocklist('Pentesters') do |req|
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 5.minutes) do
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} || req.path.include?('/etc/passwd') ||
        req.path.include?('wp-admin') || req.path.include?('wp-login')
    end
  end

  Rack::Attack.throttle('req/ip', limit: 10, period: 5.seconds) { |req| req.ip unless req.path.match(%r{\A/sidekiq}) }

  Rack::Attack.blocklist('Block IP') do |req|
    Rack::Attack::Allow2Ban.filter("throttle-ban-#{req.ip}", maxretry: 10, findtime: 5.seconds, bantime: 1.hours) do
      !req.path.match(%r{\A/sidekiq})
    end
  end

  Rack::Attack.blocklist('Block bots accessing search') do |req|
    !req.user_agent.match(/uptime/i) && CrawlerDetect.is_crawler?(req.user_agent) &&
      req.url =~ %r{/(offices|prosecutors)(\z|\?)}
  end

  Rack::Attack.blocklisted_responder = lambda { |request| [503, {}, ['Blocked']] }
  Rack::Attack.throttled_responder = lambda { |request| [503, {}, ["Server Error\n"]] }
end
