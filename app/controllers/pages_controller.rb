class PagesController < ApplicationController
  def home
    puts "HOME"
    if @@first_execution
      puts "YA SE EJECUTO"
    else
      @@first_execution = true
      handler = Handler.new
      handler.satisfy_inventory_level1_job
      handler.satisfy_inventory_level2_job
      handler.satisfy_inventory_level1_groups_job

    end
  end

end
