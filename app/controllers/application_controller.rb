class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  @@secret_key = "RAPrFLl620Cg$o"
  
  def hash(data, secret_key)
    require 'base64'
    require 'cgi'
    require 'openssl'
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), secret_key.encode("ASCII"), data.encode("ASCII"))
    signature = Base64.encode64(hmac).chomp
    return signature
  end

end
