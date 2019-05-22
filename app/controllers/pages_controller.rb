class PagesController < ApplicationController
  def home
    puts "HOME"
    #handler = Handler.new
    #handler.empty_reception
    ftp = Ftp.new
    ftp.execute
  end

end
