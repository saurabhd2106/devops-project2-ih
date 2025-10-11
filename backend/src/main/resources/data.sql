INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Classic Sesame Bun','buns',1.50,'Fresh sesame seed bun','/images/buns/sesame-bun.jpg',1,1
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Classic Sesame Bun');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Whole Wheat Bun','buns',1.75,'Healthy whole wheat bun','/images/buns/whole-wheat-bun.jpg',1,2
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Whole Wheat Bun');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Brioche Bun','buns',2.00,'Rich and buttery brioche bun','/images/buns/brioche-bun.jpg',1,3
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Brioche Bun');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Gluten-Free Bun','buns',2.25,'Gluten-free alternative bun','/images/buns/gluten-free-bun.jpg',1,4
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Gluten-Free Bun');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Beef Patty','patties',4.50,'Juicy 100% beef patty','/images/patties/beef-patty.jpg',1,1
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Beef Patty');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Chicken Breast','patties',4.25,'Grilled chicken breast','/images/patties/chicken-breast.jpg',1,2
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Chicken Breast');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Turkey Patty','patties',4.00,'Lean turkey patty','/images/patties/turkey-patty.jpg',1,3
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Turkey Patty');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Veggie Patty','patties',3.75,'Plant-based veggie patty','/images/patties/veggie-patty.jpg',1,4
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Veggie Patty');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Salmon Patty','patties',5.50,'Fresh salmon patty','/images/patties/salmon-patty.jpg',1,5
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Salmon Patty');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Lettuce','toppings',0.50,'Fresh crisp lettuce','/images/toppings/lettuce.jpg',1,1
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Lettuce');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Tomato','toppings',0.75,'Fresh tomato slices','/images/toppings/tomato.jpg',1,2
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Tomato');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Onion','toppings',0.50,'Raw or grilled onions','/images/toppings/onion.jpg',1,3
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Onion');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Pickles','toppings',0.50,'Dill pickle slices','/images/toppings/pickles.jpg',1,4
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Pickles');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Mushrooms','toppings',1.00,'Sautéed mushrooms','/images/toppings/mushrooms.jpg',1,5
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Mushrooms');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Bacon','toppings',1.50,'Crispy bacon strips','/images/toppings/bacon.jpg',1,6
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Bacon');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Avocado','toppings',1.25,'Fresh avocado slices','/images/toppings/avocado.jpg',1,7
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Avocado');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Jalapeños','toppings',0.75,'Spicy jalapeño peppers','/images/toppings/jalapenos.jpg',1,8
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Jalapeños');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Ketchup','sauces',0.25,'Classic tomato ketchup','/images/sauces/ketchup.jpg',1,1
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Ketchup');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Mustard','sauces',0.25,'Yellow mustard','/images/sauces/mustard.jpg',1,2
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Mustard');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Mayo','sauces',0.25,'Creamy mayonnaise','/images/sauces/mayo.jpg',1,3
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Mayo');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'BBQ Sauce','sauces',0.50,'Smoky BBQ sauce','/images/sauces/bbq-sauce.jpg',1,4
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='BBQ Sauce');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Ranch','sauces',0.50,'Creamy ranch dressing','/images/sauces/ranch.jpg',1,5
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Ranch');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Sriracha','sauces',0.50,'Spicy sriracha sauce','/images/sauces/sriracha.jpg',1,6
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Sriracha');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Aioli','sauces',0.75,'Garlic aioli','/images/sauces/aioli.jpg',1,7
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Aioli');

INSERT INTO ingredients (name, category, price, description, image_url, is_available, sort_order)
SELECT 'Buffalo Sauce','sauces',0.50,'Spicy buffalo sauce','/images/sauces/buffalo-sauce.jpg',1,8
WHERE NOT EXISTS (SELECT 1 FROM dbo.ingredients WHERE name='Buffalo Sauce');
