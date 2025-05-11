
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();

async function seedRecipes() {
  const col = db.collection('recipes');

  const existing = await col.limit(1).get();
  if (!existing.empty) {
    console.log('✅ recipes already seeded');
    return;
  }

  const defaults = [
    {
      id:          'avocado_toast',
      title:       'Avocado Toast',
      description: 'Crunchy toast topped with creamy avocado and a hint of lemon.',
      calories:    250,
      category:    'Breakfast',
      image:       'https://example.com/images/avocado_toast.jpg',
      ingredients: ['Avocado', 'Bread', 'Olive Oil', 'Salt', 'Pepper'],
      steps: [
        'Toast the bread until golden.',
        'Mash avocado with olive oil, salt, and pepper.',
        'Spread mixture on toast and serve immediately.'
      ],
      isVegetarian: true,
      allergens:    ['gluten']
    },
    {
      id:          'banana_smoothie',
      title:       'Banana Smoothie',
      description: 'A creamy banana smoothie with a touch of honey and milk.',
      calories:    180,
      category:    'Beverage',
      image:       'https://example.com/images/banana_smoothie.jpg',
      ingredients: ['Banana', 'Milk', 'Honey'],
      steps: [
        'Combine banana, milk, and honey in a blender.',
        'Blend until smooth and pour into a glass.'
      ],
      isVegetarian: true,
      allergens:    ['dairy']
    },

    {
      id:          'broccoli_salad',
      title:       'Broccoli Salad',
      description: 'Fresh broccoli florets tossed in a light vinaigrette.',
      calories:    120,
      category:    'Lunch',
      image:       'https://example.com/images/broccoli_salad.jpg',
      ingredients: ['Broccoli', 'Olive Oil', 'Salt', 'Pepper', 'Lemon'],
      steps: [
        'Steam broccoli until tender-crisp, then cool.',
        'Toss with olive oil, lemon juice, salt, and pepper.'
      ],
      isVegetarian: true,
      allergens:    []
    },
    {
      id:          'carrot_stirfry',
      title:       'Garlic Carrot Stir-Fry',
      description: 'Quick stir-fry of carrots with garlic and a splash of soy.',
      calories:    140,
      category:    'Side',
      image:       'https://example.com/images/carrot_stirfry.jpg',
      ingredients: ['Carrot', 'Olive Oil', 'Salt', 'Pepper', 'Garlic'],
      steps: [
        'Slice carrots thinly.',
        'Heat oil, sauté garlic, then add carrots.',
        'Season with salt, pepper, and cook until tender.'
      ],
      isVegetarian: true,
      allergens:    []
    },

    {
      id:          'cheddar_omelette',
      title:       'Cheddar Omelette',
      description: 'Fluffy egg omelette filled with melted cheddar cheese.',
      calories:    300,
      category:    'Breakfast',
      image:       'https://example.com/images/cheddar_omelette.jpg',
      ingredients: ['Egg', 'Cheddar Cheese', 'Milk', 'Salt', 'Pepper', 'Butter'],
      steps: [
        'Beat eggs with milk, salt, and pepper.',
        'Melt butter in pan, pour egg mixture.',
        'When almost set, sprinkle cheese, fold and serve.'
      ],
      isVegetarian: true,
      allergens:    ['egg','dairy']
    },
    {
      id:          'eggs_benedict',
      title:       'Eggs Benedict',
      description: 'Poached eggs and ham on an English muffin, topped with hollandaise.',
      calories:    450,
      category:    'Brunch',
      image:       'https://example.com/images/eggs_benedict.jpg',
      ingredients: ['Egg', 'Bread', 'Butter', 'Lemon', 'Salt', 'Pepper'],
      steps: [
        'Poach eggs until whites are set.',
        'Toast muffin halves, top each with poached egg and butter.',
        'Drizzle with lemon-butter sauce, season and serve.'
      ],
      isVegetarian: false,
      allergens:    ['egg','gluten','dairy']
    },

    {
      id:          'rice_pilaf',
      title:       'Herbed Rice Pilaf',
      description: 'Fluffy rice cooked in broth with fresh herbs.',
      calories:    220,
      category:    'Lunch',
      image:       'https://example.com/images/rice_pilaf.jpg',
      ingredients: ['Rice', 'Olive Oil', 'Salt', 'Pepper', 'Basil', 'Oregano'],
      steps: [
        'Sauté rice in olive oil.',
        'Add water or broth, bring to boil.',
        'Stir in chopped basil and oregano, cover and simmer until rice is done.'
      ],
      isVegetarian: true,
      allergens:    []
    },
    {
      id:          'pasta_alfredo',
      title:       'Pasta Alfredo',
      description: 'Rich and creamy pasta with Parmesan sauce.',
      calories:    500,
      category:    'Dinner',
      image:       'https://example.com/images/pasta_alfredo.jpg',
      ingredients: ['Pasta', 'Butter', 'Milk', 'Parmesan', 'Salt', 'Pepper'],
      steps: [
        'Cook pasta until al dente.',
        'Melt butter, stir in milk and cheese to make sauce.',
        'Toss pasta in sauce and serve hot.'
      ],
      isVegetarian: true,
      allergens:    ['gluten','dairy']
    },

    {
      id:          'grilled_chicken_breast',
      title:       'Grilled Chicken Breast',
      description: 'Juicy chicken breast seasoned simply with salt and pepper.',
      calories:    270,
      category:    'Dinner',
      image:       'https://example.com/images/grilled_chicken_breast.jpg',
      ingredients: ['Chicken Breast', 'Olive Oil', 'Salt', 'Pepper'],
      steps: [
        'Brush chicken with oil, season with salt and pepper.',
        'Grill 6–7 minutes per side until cooked through.'
      ],
      isVegetarian: false,
      allergens:    []
    },
    {
      id:          'beef_stroganoff',
      title:       'Beef Stroganoff',
      description: 'Tender beef in a creamy mushroom sauce over noodles.',
      calories:    480,
      category:    'Dinner',
      image:       'https://example.com/images/beef_stroganoff.jpg',
      ingredients: ['Beef Steak','Mushrooms','Onion','Butter','Flour','Milk','Salt','Pepper'],
      steps: [
        'Sauté beef strips, remove.',
        'Cook onions & mushrooms in butter, stir in flour.',
        'Add milk to make sauce, return beef, simmer 5 min.',
        'Serve over egg noodles.'
      ],
      isVegetarian: false,
      allergens:    ['dairy','gluten']
    },

    {
      id:          'pepper_steak',
      title:       'Pepper Steak',
      description: 'Sliced steak stir-fried with bell peppers in peppercorn sauce.',
      calories:    400,
      category:    'Dinner',
      image:       'https://example.com/images/pepper_steak.jpg',
      ingredients: ['Beef Steak','Bell Pepper','Olive Oil','Salt','Pepper'],
      steps: [
        'Stir fry steak strips, remove.',
        'Stir fry sliced peppers, return beef.',
        'Season heavily with cracked pepper and salt.'
      ],
      isVegetarian: false,
      allergens:    []
    },
    {
      id:          'basil_pesto_pasta',
      title:       'Basil Pesto Pasta',
      description: 'Bright green pesto tossed with hot pasta.',
      calories:    350,
      category:    'Lunch',
      image:       'https://example.com/images/basil_pesto_pasta.jpg',
      ingredients: ['Pasta','Basil','Olive Oil','Parmesan','Salt','Pepper','Garlic'],
      steps: [
        'Blend basil, oil, cheese, garlic into pesto.',
        'Toss with hot pasta and serve.'
      ],
      isVegetarian: true,
      allergens:    ['dairy','gluten']
    },


    {
      id:          'ketchup_meatloaf',
      title:       'Ketchup-Glazed Meatloaf',
      description: 'Classic meatloaf topped with a tangy ketchup glaze.',
      calories:    420,
      category:    'Dinner',
      image:       'https://example.com/images/ketchup_meatloaf.jpg',
      ingredients: ['Beef Steak (ground)','Bread','Egg','Onion','Ketchup','Salt','Pepper'],
      steps: [
        'Mix beef, breadcrumbs, egg, onion, salt, pepper.',
        'Shape into loaf, coat top with ketchup.',
        'Bake at 180°C (350°F) for 45 minutes.'
      ],
      isVegetarian: false,
      allergens:    ['gluten','egg']
    },
    {
      id:          'olive_oil_dressing',
      title:       'Simple Olive Oil Dressing',
      description: 'A light vinaigrette perfect for salads.',
      calories:    80,
      category:    'Salad',
      image:       'https://example.com/images/olive_oil_dressing.jpg',
      ingredients: ['Olive Oil','Salt','Pepper','Lemon'],
      steps: [
        'Whisk oil with lemon juice, salt, and pepper.',
        'Drizzle over greens and toss.'
      ],
      isVegetarian: true,
      allergens:    []
    },

    {
      id:          'coffee_latte',
      title:       'Café Latte',
      description: 'Creamy steamed milk with a shot of espresso.',
      calories:    150,
      category:    'Beverage',
      image:       'https://example.com/images/coffee_latte.jpg',
      ingredients: ['Coffee','Milk'],
      steps: [
        'Brew espresso or strong coffee.',
        'Steam milk and pour over coffee.'
      ],
      isVegetarian: true,
      allergens:    ['dairy']
    },
    {
      id:          'tea_lemon',
      title:       'Lemon Tea',
      description: 'Hot tea brightened with fresh lemon slices.',
      calories:    5,
      category:    'Beverage',
      image:       'https://example.com/images/tea_lemon.jpg',
      ingredients: ['Tea','Lemon'],
      steps: [
        'Brew tea to taste.',
        'Serve with lemon slice.'
      ],
      isVegetarian: true,
      allergens:    []
    },

    {
      id:          'cookie_milk_pairing',
      title:       'Cookie & Milk',
      description: 'Classic snack of buttery cookie dipped in cold milk.',
      calories:    200,
      category:    'Snack',
      image:       'https://example.com/images/cookie_milk_pairing.jpg',
      ingredients: ['Cookie','Milk'],
      steps: [
        'Place cookie on plate.',
        'Pour milk in glass and enjoy together.'
      ],
      isVegetarian: true,
      allergens:    ['dairy','gluten']
    },
    {
      id:          'chips_n_salsa',
      title:       'Chips & Salsa',
      description: 'Crispy potato chips served with zesty tomato salsa.',
      calories:    180,
      category:    'Snack',
      image:       'https://example.com/images/chips_n_salsa.jpg',
      ingredients: ['Chips','Tomato','Onion','Salt','Pepper','Olive Oil'],
      steps: [
        'Chop tomato & onion, mix with oil, salt, pepper.',
        'Serve salsa alongside chips.'
      ],
      isVegetarian: true,
      allergens:    []
    },

    {
      id:          'salmon_teriyaki',
      title:       'Salmon Teriyaki',
      description: 'Glazed salmon fillet with homemade teriyaki sauce.',
      calories:    380,
      category:    'Dinner',
      image:       'https://example.com/images/salmon_teriyaki.jpg',
      ingredients: ['Salmon','Soy Sauce','Sugar','Garlic','Ginger'],
      steps: [
        'Simmer soy sauce, sugar, garlic, ginger to make glaze.',
        'Brush on salmon and broil until caramelized.'
      ],
      isVegetarian: false,
      allergens:    ['soy']
    },
    {
      id:          'shrimp_scampi',
      title:       'Shrimp Scampi',
      description: 'Succulent shrimp sautéed in garlic-butter sauce over pasta.',
      calories:    420,
      category:    'Dinner',
      image:       'https://example.com/images/shrimp_scampi.jpg',
      ingredients: ['Shrimp','Butter','Garlic','Pasta','Salt','Pepper'],
      steps: [
        'Cook pasta until al dente.',
        'Sauté garlic in butter, add shrimp until pink.',
        'Toss shrimp and sauce with pasta.'
      ],
      isVegetarian: false,
      allergens:    ['shellfish','gluten','dairy']
    },

    {
      id:          'croissant_sandwich',
      title:       'Croissant Breakfast Sandwich',
      description: 'Buttery croissant filled with egg, cheese, and ham.',
      calories:    350,
      category:    'Breakfast',
      image:       'https://example.com/images/croissant_sandwich.jpg',
      ingredients: ['Croissant','Egg','Cheddar Cheese','Ham','Butter'],
      steps: [
        'Slice croissant, layer ham and cheese.',
        'Cook egg and place on top, close sandwich and serve.'
      ],
      isVegetarian: false,
      allergens:    ['gluten','dairy','egg']
    },
    {
      id:          'bagel_with_cream_cheese',
      title:       'Bagel with Cream Cheese',
      description: 'Toasted bagel generously spread with cream cheese.',
      calories:    320,
      category:    'Breakfast',
      image:       'https://example.com/images/bagel_with_cream_cheese.jpg',
      ingredients: ['Bagel','Cream Cheese','Salt'],
      steps: [
        'Toast bagel halves to desired crispness.',
        'Spread cream cheese and sprinkle a pinch of salt.'
      ],
      isVegetarian: true,
      allergens:    ['gluten','dairy']
    }
  ];

  console.log(` Seeding ${defaults.length} recipes…`);
  for (const r of defaults) {
    await col.doc(r.id).set({
      title:        r.title,
      description:  r.description,
      calories:     r.calories,
      category:     r.category,
      image:        r.image,
      ingredients:  r.ingredients,
      steps:        r.steps,
      isVegetarian: r.isVegetarian,
      allergens:    r.allergens,
      createdAt:    admin.firestore.FieldValue.serverTimestamp()
    });
    console.log(`  • ${r.title}`);
  }
  console.log(' recipes seeded!');
}

seedRecipes()
  .then(() => process.exit(0))
  .catch(err => {
    console.error(' seedRecipes error:', err);
    process.exit(1);
  });
