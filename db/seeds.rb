# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'roo'

xlxs = Roo::Spreadsheet.open('./lib/assets/Productos.xlsx')


# Productos

productos = xlxs.sheet('Productos')

for i in 2..79
  Product.create(
    sku: productos.cell('A', i),
    name: productos.cell('B', i),
    description: productos.cell('C', i),
    sell_price: productos.cell('D', i),
    ingredients: productos.cell('E', i),
    used_by: productos.cell('F', i),
    expected_duration_hours: productos.cell('G', i),
    equivalence_units_hold: productos.cell('H', i),
    unit: productos.cell('I', i),
    production_lot: productos.cell('J', i),
    expected_time_production_mins: productos.cell('K', i),
    groups: productos.cell('L', i),
    total_productor_groups: productos.cell('M', i)
  )
end

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
    unit2: productos.cell('I', i),
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
    space_for_receive_production: recetas.cell('L', i)
  )
end


# Asignacion

asignacion = xlxs.sheet('Asignación')

for i in  2..71
  Assignation.create(
    sku: asignacion.cell('A', i),
    name: asignacion.cell('B', i),
    group: asignacion.cell('C', i),
  )
end


# stock mínimo

stock = xlxs.sheet('Stock mínimo')

for i in 2..24
  MinimumStock.create(
    sku: stock.cell('A', i),
    name: stock.cell('B', i),
    number_of_products: stock.cell('C', i),
    minimum_stock: stock.cell('D', i),
  )
end
