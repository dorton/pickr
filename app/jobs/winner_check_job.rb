class WinnerCheckJob < ApplicationJob
  queue_as :default

  def perform(*args)
    WinnerChecker.call(Calendar.current_week.value)
  end
end
