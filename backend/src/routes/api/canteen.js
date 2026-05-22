const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (_req, res) => {
  const canteens = db.prepare('SELECT * FROM canteens ORDER BY name').all();
  const dishes = db.prepare('SELECT * FROM dishes ORDER BY canteen_id, name').all();
  res.json({
    canteens: canteens.map((c) => ({ id: c.id, name: c.name })),
    dishes: dishes.map((d) => ({
      id: d.id,
      canteenId: d.canteen_id,
      name: d.name,
      price: d.price,
      nutrition: JSON.parse(d.nutrition_json || '{}'),
      rating: d.rating,
      description: d.description || '',
    })),
  });
});

router.get('/:id', authRequired, (req, res) => {
  const row = db.prepare('SELECT * FROM dishes WHERE id = ?').get(req.params.id);
  if (!row) return res.status(404).json({ error: '菜品不存在' });
  res.json({
    dish: {
      id: row.id,
      canteenId: row.canteen_id,
      name: row.name,
      price: row.price,
      nutrition: JSON.parse(row.nutrition_json || '{}'),
      rating: row.rating,
      description: row.description || '',
    },
  });
});

module.exports = router;
