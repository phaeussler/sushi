# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'roo'

xlxs = Roo::Spreadsheet.open('./lib/assets/Productos.xlsx')


# Ingredientes

ingredientes = xlxs.sheet('Ingredientes')

for i in 2..192
  Ingredient.create(
    sku_product: ingredientes.cell('A', i),
    name_product: ingredientes.cell('B', i),
    sku_ingredient: ingredientes.cell('C', i),
    name_ingredient: ingredientes.cell('D', i),
    quantity: ingredientes.cell('E', i),
    unit1: ingredientes.cell('F', i),
    production_lot: ingredientes.cell('G', i),
    quantity_for_lot: ingredientes.cell('H', i),
    unit2: ingredientes.cell('I', i),
    equivalence_unit_hold: ingredientes.cell('J', i),
  )
end


# Resumen recetas productos

recetas = xlxs.sheet('Resumen recetas productos')

for i in  2..79
  Receipt.create(
    sku: recetas.cell('A', i),
    name: recetas.cell('B', i),
    description: recetas.cell('C', i),
    ingredients_number: recetas.cell('D', i),
    ingredient1: recetas.cell('E', i),
    ingredient2: recetas.cell('F', i),
    ingredient3: recetas.cell('G', i),
    ingredient4: recetas.cell('H', i),
    ingredient5: recetas.cell('I', i),
    ingredient6: recetas.cell('J', i),
    space_for_production: recetas.cell('K', i),
    space_for_receive_production: recetas.cell('L', i),
    production_type: recetas.cell('M', i) # nuevo
  )
end


# Asignacion

asignacion = xlxs.sheet('Asignación')

for i in  2..113
  Assignation.create(
    sku: asignacion.cell('A', i),
    name: asignacion.cell('B', i),
    group: asignacion.cell('C', i),
  )
end


# stock mínimo

stock = xlxs.sheet('Stock mínimo')

for i in 2..26
  MinimumStock.create(
    sku: stock.cell('A', i),
    name: stock.cell('B', i),
    number_of_products: stock.cell('C', i),
    minimum_stock: stock.cell('D', i),
    ingredients_number: stock.cell('E', i), # nuevo
    ingredient_name: stock.cell('F', i), # nuevo
    sku_ingredient: stock.cell('G', i) # nuevo
  )
end

group_ids = xlxs.sheet('Ids de grupos')

for i in 2..15
  GroupIdOc.create(
    group: group_ids.cell('A', i),
    id_development: group_ids.cell('B', i),
    id_production: group_ids.cell('C', i)
  )
end

# Productos

productos = xlxs.sheet('Productos')

for i in 2..79
  sku = productos.cell('A', i)
  min = MinimumStock.find_by sku: sku
  min = min ? min["minimum_stock"] : 0
  if sku<=1016
    min = [min, 60].max
    max = 150
    level = 1
  elsif sku < 10000
    min = [min, 40].max
    max = 100
    level = 2
  else
    min = [min, 1].max
    max = 50
    level = 3
  end
  Product.create(
    sku: productos.cell('A', i),
    name: productos.cell('B', i),
    description: productos.cell('C', i),
    cost_lot_production: productos.cell('D', i), # nuevo
    sell_price: productos.cell('E', i),
    ingredients: productos.cell('F', i),
    used_by: productos.cell('G', i),
    expected_duration_hours: productos.cell('H', i),
    equivalence_units_hold: productos.cell('I', i),
    unit: productos.cell('J', i),
    production_lot: productos.cell('K', i),
    expected_time_production_mins: productos.cell('L', i),
    groups: productos.cell('M', i),
    total_productor_groups: productos.cell('N', i),
    production_type: productos.cell('AC', i), # nuevo
    min: min,
    max: max,
    level: level
  )
end

ShoppingCartProduct.create(title: "California Maki Sésamo", description:"Roll kanikama, palta, envuelto en sésamo", sku:10001, price: 4500)
ShoppingCartProduct.create(title: "California Maki Masago", description:"Roll kanikama, palta, envuelto en masago", sku:10002, price: 4500)
ShoppingCartProduct.create(title: "California Ebi Mix", description:"Roll kanikama, palta, envuelto en mezcla de masago y sésamo", sku:10003, price: 4700)
ShoppingCartProduct.create(title: "California Ebi Sésamo", description:"Roll con camarón, palta, envuelto en sésamo", sku:10004, price: 4700)
ShoppingCartProduct.create(title: "California Sake Masago", description:"Roll con camarón, palta, envuelto en masago", sku:10005, price: 4700)
ShoppingCartProduct.create(title: "California Sake Sésamo", description:"Roll salmón, palta, envuelto en sésamo", sku:10006, price: 4900)
ShoppingCartProduct.create(title: "California Sake Masago", description:"Roll salmón, palta, envuelto en masago", sku:10007, price: 4900)
ShoppingCartProduct.create(title: "California Maguro Sésamo", description:"Roll atún, palta, envuelto en sésamo", sku:10008, price: 4900)
ShoppingCartProduct.create(title: "California Maguro Masago", description:"Roll atún, palta, envuelto en masago", sku:10009, price: 4900)
ShoppingCartProduct.create(title: "Ebi", description:"Roll con camarón y palta, envuelto en palta", sku:10010, price: 4900)
ShoppingCartProduct.create(title: "Ebi Especial", description:"Roll con camarón, queso crema, cebollín, envuelto en palta", sku:10011, price: 5700)
ShoppingCartProduct.create(title: "Turo", description:"Roll con salmón ahumado, camarón y queso crema, envuelto en palta", sku:10012, price: 5700)
ShoppingCartProduct.create(title: "Coca", description:"Roll con camarón y queso crema, envuelto en palta", sku:10013, price: 5700)
ShoppingCartProduct.create(title: "Akita", description:"Roll kanikama y queso crema, envuelto en palta", sku:10014, price: 4900)
ShoppingCartProduct.create(title: "Delicia", description:"Roll con camarón, queso crema y ciboulette, envuelto en palta", sku:10015, price: 5700)
ShoppingCartProduct.create(title: "Beto", description:"Roll con salmón, camarón y queso crema, envuelto en palta", sku:10016, price: 5700)
ShoppingCartProduct.create(title: "Avocado", description:"Roll salmón y queso crema, envuelto en palta", sku:10017, price: 5700)
ShoppingCartProduct.create(title: "Maki Salmón", description:"Kanikama, palta y queso crema envuelto en salmón", sku:10018, price: 5700)
ShoppingCartProduct.create(title: "Ebi Salmón", description:"Camarón y palta envuelto en salmón", sku:10019, price: 5700)
ShoppingCartProduct.create(title: "Ebi Salmón Especial", description:"Camarón, queso crema y cebollín, envuelto en salmón", sku:10020, price: 5900)
ShoppingCartProduct.create(title: "Maguro Salmón", description:"Atún, palta y cebollín, envuelto en salmón", sku:10021, price: 5900)
ShoppingCartProduct.create(title: "Sake Ciboulette", description:"Salmón, palta y queso crema envuelto en Ciboulette", sku:10022, price: 5500)
ShoppingCartProduct.create(title: "Maguro Ciboulette", description:"Atún, palta y queso crema envuelto en Ciboulette", sku:10023, price: 5500)
ShoppingCartProduct.create(title: "Vegan Sésamo", description:"Roll vegano con palta, cebollín y ciboulette envuelto en sésamo", sku:10024, price: 4900)
ShoppingCartProduct.create(title: "Vegan Masago", description:"Roll vegano con palta, cebollín y ciboulette envuelto en masago", sku:10025, price: 4900)
ShoppingCartProduct.create(title: "Nigiri Avocado", description:"Nigiri con salmón, palta y queso crema", sku:20001, price: 2700)
ShoppingCartProduct.create(title: "Nigiri Ebi", description:"Nigiri con camarón", sku:20002, price: 2700)
ShoppingCartProduct.create(title: "Nigiri Sake", description:"Nigiri con salmón", sku:20003, price: 2700)
ShoppingCartProduct.create(title: "Nigiri Maguro", description:"Nigiri con atún", sku:20004, price: 2700)
ShoppingCartProduct.create(title: "Nigiri Maguro Especial", description:"Nigiri con atún, palta y queso crema", sku:20005, price: 2700)
ShoppingCartProduct.create(title: "Sashimi Salmón 9 cortes", description:"Sashimi de salmón, 9 cortes", sku:30001, price: 7900)
ShoppingCartProduct.create(title: "Sashimi Salmón 12 cortes", description:"Sashimi de salmón, 12 cortes", sku:30002, price: 9900)
ShoppingCartProduct.create(title: "Sashimi Salmón 15 cortes", description:"Sashimi de salmón, 15 cortes", sku:30003, price: 12500)
ShoppingCartProduct.create(title: "Sashimi Atún 9 cortes", description:"Sashimi de atún, 9 cortes", sku:30004, price: 7900)
ShoppingCartProduct.create(title: "Sashimi Atún 12 cortes", description:"Sashimi de atún, 12 cortes", sku:30005, price: 9900)
ShoppingCartProduct.create(title: "Sashimi Atún 15 cortes", description:"Sashimi de atún, 15 cortes", sku:30006, price: 12500)
ShoppingCartProduct.create(title: "Sashimi Mix 12 cortes", description:"Mix de 6 cortes de sashimi de atún y 6 cortes de sashimi de salmón", sku:30007, price: 9900)
ShoppingCartProduct.create(title: "Sashimi Mix 18 cortes", description:"Mix de 9 cortes de sashimi de atún y 9 cortes de sashimi de salmón", sku:30008, price: 15990)
