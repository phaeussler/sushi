class FtpordersController < ApplicationController

  # GET /ftporders
  def index
    msg = "FTP"
    render json: msg,   :status => 200
  end


  '''Manejar la respuesta del otro grupo'''
  '''POST a la URL'''
  # POST/ftporders
  def endpoint_notificacion
  end




end
