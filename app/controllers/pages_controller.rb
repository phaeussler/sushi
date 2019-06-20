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
<<<<<<< HEAD
      handler.satisfy_inventory_level1_groups_job
=======
      handler.satisfy_inventory_level1_gropus_job
>>>>>>> 6f5077b8d314623026ce252524d88606f00e5af9

    end
  end

end
