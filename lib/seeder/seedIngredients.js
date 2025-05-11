const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedIngredients() {
  const col = db.collection('ingredients');
  const existing = await col.limit(1).get();
  if (!existing.empty) {
    console.log('ingredients already seeded');
    return;
  }

  const defaults = [
    { id: 'avocado',        name: 'Avocado',           categoryId: 'Fruits' },
    { id: 'banana',         name: 'Banana',            categoryId: 'Fruits' },
    { id: 'strawberry',     name: 'Strawberry',        categoryId: 'Fruits' },
    { id: 'spinach',        name: 'Spinach',           categoryId: 'Vegetables' },
    { id: 'carrot',         name: 'Carrot',            categoryId: 'Vegetables' },
    { id: 'broccoli',       name: 'Broccoli',          categoryId: 'Vegetables' },
    { id: 'milk',           name: 'Milk',              categoryId: 'Dairy' },
    { id: 'cheddar_cheese', name: 'Cheddar Cheese',    categoryId: 'Dairy' },
    { id: 'egg',            name: 'Egg',               categoryId: 'Dairy' },
    { id: 'bread',          name: 'Bread',             categoryId: 'Grains' },
    { id: 'rice',           name: 'Rice',              categoryId: 'Grains' },
    { id: 'pasta',          name: 'Pasta',             categoryId: 'Grains' },
    { id: 'chicken_breast', name: 'Chicken Breast',    categoryId: 'Meat' },
    { id: 'beef_steak',     name: 'Beef Steak',        categoryId: 'Meat' },
    { id: 'pork_chop',      name: 'Pork Chop',         categoryId: 'Meat' },
    { id: 'salt',           name: 'Salt',              categoryId: 'Spices' },
    { id: 'pepper',         name: 'Black Pepper',      categoryId: 'Spices' },
    { id: 'basil',          name: 'Basil',             categoryId: 'Herbs' },
    { id: 'oregano',        name: 'Oregano',           categoryId: 'Herbs' },
    { id: 'olive_oil',      name: 'Olive Oil',         categoryId: 'Condiments' },
    { id: 'ketchup',        name: 'Ketchup',           categoryId: 'Condiments' },
    { id: 'coffee',         name: 'Coffee',            categoryId: 'Beverages' },
    { id: 'tea',            name: 'Tea',               categoryId: 'Beverages' },
    { id: 'cookie',         name: 'Cookie',            categoryId: 'Snacks' },
    { id: 'chips',          name: 'Potato Chips',      categoryId: 'Snacks' },
    { id: 'salmon',         name: 'Salmon',            categoryId: 'Seafood' },
    { id: 'shrimp',         name: 'Shrimp',            categoryId: 'Seafood' },
    { id: 'croissant',      name: 'Croissant',         categoryId: 'Bakery' },
    { id: 'bagel',          name: 'Bagel',             categoryId: 'Bakery' },
  ];

  console.log(`🌱 Seeding ${defaults.length} ingredients…`);
  for (const ing of defaults) {
    await col.doc(ing.id).set({
      name:       ing.name,
      categoryId: ing.categoryId,
    });
    console.log(`  • ${ing.name} (${ing.categoryId})`);
  }
  console.log(' ingredients seeded!');
}
seedIngredients()
  .then(() => {
    process.exit(0);
  })
  .catch(err => {
    console.error(err);
    process.exit(1);
  });

