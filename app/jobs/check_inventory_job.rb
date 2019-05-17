class CheckInventoryJob < ApplicationJob::Base
  queue_as :default

  def perform
    puts "HOLA"
  end
end

CheckInventoryJob.set(wait_until: 1.minute).perform_later
