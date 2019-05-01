json.extract! order, :id, :created_at, :updated_at, :almacenId, :sku, :cantidad
json.url order_url(order, format: :json)
