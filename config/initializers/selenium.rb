# TODO turn off on release
Selenium::WebDriver.logger.level = :debug
Selenium::WebDriver.logger.output = Rails.root.join('log', 'selenium.log')
