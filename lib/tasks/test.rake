namespace :test do
  desc 'Task description'
  task task_name: [:environment] do
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    options.add_argument("--window-size=1024,768")
    driver = Selenium::WebDriver.for(:chrome, options: options)

    driver.get('http://localhost:3000/criminality')


    driver.execute_script <<-JS
      document.getElementsByClassName('btn-group')[0].remove();
      document.getElementsByClassName('table')[0].remove();
      document.getElementById('timing').remove();
      document.getElementsByTagName('body')[0].innerHTML = document.querySelector('[data-results-for-facets]').innerHTML
    JS

    sleep 3

    driver.save_screenshot('a.png')

    `open a.png`
  end
end
