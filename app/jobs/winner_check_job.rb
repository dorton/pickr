class WinnerCheckJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ApplicationController.helpers.handle_winning_picks(ApplicationController.helpers.current_week.value)
  end

  
end
