def hash_2(data, secret_key)
    require 'base64'
    require 'cgi'
    require 'openssl'
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), secret_key.encode("ASCII"), data.encode("ASCII"))
    signature = Base64.encode64(hmac).chomp
    return signature
end

sku = 1101
cantidad = 10
api_key = "RAPrFLl620Cg$o"
puts hash_2("PUT#{sku}#{cantidad}", api_key)