const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedCategories() {
  const col = db.collection('ingredientCategories');
  const existing = await col.limit(1).get();
  if (!existing.empty) {
    console.log(' ingredientCategories already seeded');
    return;
  }

  const defaults = [
    { id: 'Meat',       name: 'Meat',            icon: 'lunch_dining',   color: 'F44336' },
    { id: 'Fruits',     name: 'Fruits',          icon: 'nutrition',      color: 'FF9800' },
    { id: 'Dairy',      name: 'Dairy',           icon: 'egg',            color: '2196F3' },
    { id: 'Grains',     name: 'Grains & Bread',  icon: 'grain',          color: 'FFC107' },
    { id: 'Spices',     name: 'Spices & Herbs',  icon: 'spa',            color: '9C27B0' },
    { id: 'Beverages',  name: 'Beverages',       icon: 'local_cafe',     color: '009688' },
    { id: 'Snacks',     name: 'Snacks',          icon: 'cookie',         color: 'FFEB3B' },
    { id: 'Seafood',    name: 'Seafood',         icon: 'set_meal',       color: '2196F3' },
    { id: 'Bakery',     name: 'Bakery',          icon: 'bakery_dining',  color: '8D6E63' },
    { id: 'Condiments', name: 'Condiments',      icon: 'restaurant',     color: '795548' },
    { id: 'Herbs',      name: 'Herbs',           icon: 'eco',            color: '388E3C' },
  ];

  console.log(`🌱 Seeding ${defaults.length} categories…`);
  for (const cat of defaults) {
    await col.doc(cat.id).set({
      name:  cat.name,
      icon:  cat.icon,
      color: cat.color,
    });
    console.log(`  • ${cat.name}`);
  }
  console.log(' ingredientCategories seeded!');
}

seedCategories()
  .catch(err => {
    console.error('Seed failed:', err);
    process.exit(1);
  })
  .then(() => process.exit());
