class PagesController < ApplicationController
  def home
    puts "HOME"
    #handler = Handler.new
    #handler.empty_reception
    # ftp = Ftp.new
    # ftp.files
    ftp = FTP.new
    ftp.files
  end
  
end
