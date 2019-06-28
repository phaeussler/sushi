require 'json'

module PurchaseOrdersHelper

    def get_items_json order_items
        items_dict = {}
        order_items.each do |item|
            items_dict[item.shopping_cart_product.sku] = item.quantity
        end
        puts items_dict.to_json
        items_dict.to_json
    end

    def generar_boleta(proveedor, cliente, total)
        @server_boleta = "dev"
    # hash_str = hash(method_str, api_key)
        puts "Se inicio la generación de boleta"
        uri = 'sii/boleta'
        base_url ="https://integracion-2019-#{@server_boleta}.herokuapp.com/"
        body = {
            "proveedor": proveedor,
            "cliente": cliente,
            "total": total
        }

        begin
            puts "Se envia el request"
            request = HTTParty.post(base_url+uri,
                body:body.to_json,
                headers:{
                "Content-Type": "application/json"
            })

            return request.code, JSON.parse(request.body) ,request.headers
        rescue JSON::ParserError => e
            puts "generar_boleta, error al parcear el body"
            return 500, {}, {}
        end
    end

    def pagar_orden(boleta_id, order_id)
        # FIXME: joaquin. CAMBIAR A "prod" CUANDO PASE A PROD
        server = "dev"
        # FIXME: joaquin. CAMBIAR A "prod" CUANDO PASE A PROD
        isLocal = "local"

        success_url_local = "http%3A%2F%2F127.0.0.1%2Fpurchase_orders%2F#{order_id}%2Fsuccess"
        success_url_prod = "http%3A%2F%2Ftuerca1.ing.puc.cl%2Fpurchase_orders%2F#{order_id}%2Fsuccess"
        fail_url_local = "http%3A%2F%2F127.0.0.1%2Fpurchase_orders%2F#{order_id}%2Ffail"
        fail_url_prod = "http%3A%2F%2Ftuerca1.ing.puc.cl%2Fpurchase_orders%2F#{order_id}%2Ffail"

        
        url_ok = (isLocal == "local") ? success_url_local : success_url_prod
        url_fail = (isLocal == "local") ? fail_url_local : fail_url_prod
        
        payment_url = "https://integracion-2019-#{server}.herokuapp.com/web/pagoenlinea?callbackUrl=#{url_ok}&cancelUrl=#{url_fail}&boletaId=#{boleta_id}"

        redirect_to payment_url


    end

end
