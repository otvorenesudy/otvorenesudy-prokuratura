module ExceptionHandler
  def self.run
    begin
      yield
    rescue Exception => e
      Sentry.capture_exception(e)
    end
  end
end
