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