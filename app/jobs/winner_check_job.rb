class WinnerCheckJob < ApplicationJob
  queue_as :default

  def perform(*args)
    helper.handle_winning_picks(helper.current_week)
  end

  
end
