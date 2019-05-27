class FtpordersController < ApplicationController

  # GET /ftporders
  def index
    puts "REVISANDO ORDENES"
    ftp = Ftp.new
    ftp.execute
    msg = "FTP"
    render json: msg,   :status => 200
  end


  '''Manejar la respuesta del otro grupo'''
  '''POST a la URL'''
  # POST/ftporders
  def create
    puts "HOLA"
  end




end
