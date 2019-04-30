require 'json'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  @@recepcion = "5cbd3ce444f67600049431b3"
  @@despacho = "5cbd3ce444f67600049431b4"
  @@pulmon = "5cbd3ce444f67600049431b7"
  @@cocina = "5cbd3ce444f67600049431b8"



  def hash(data, secret_key)
    require 'base64'
    require 'cgi'
    require 'openssl'
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), secret_key.encode("ASCII"), data.encode("ASCII"))
    signature = Base64.encode64(hmac).chomp
    return signature
  end

  def request_system(uri,method_str, api_key)
    hash_str = hash(method_str, api_key)
    base_url ="https://integracion-2019-dev.herokuapp.com/bodega/"
    resp = HTTParty.get("#{base_url}#{uri}",
      headers:{
        "Authorization": "INTEGRACION grupo1:#{hash_str}",
        "Content-Type": "application/json"
      })
    puts "Solicitud: #{resp.code}"
    puts JSON.parse(resp.body)
    return resp
  end


  def request_product(id, sku, api_key)
    uri = "stock?almacenId=#{id}&sku=#{sku}"
    hash_str = "GET#{id}#{sku}"
    return request_system(uri, hash_str, api_key)
  end

  def sku_with_stock(id, api_key)
    uri = "skusWithStock?almacenId=#{id}"
    hash_str = "GET#{id}"
    return request_system(uri, hash_str,api_key)
  end


  def move_product_almacen(product_id, almacen_id)

  end






end
