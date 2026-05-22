const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (_req, res) => {
  const rows = db.prepare('SELECT * FROM map_pois ORDER BY name').all();
  res.json({
    pois: rows.map((p) => ({
      id: p.id,
      name: p.name,
      lat: p.lat,
      lng: p.lng,
      description: p.description,
    })),
  });
});

module.exports = router;
