const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const q = String(req.query.q || '').trim();
  if (!q) return res.json({ courses: [], books: [], market: [] });

  const courses = db
    .prepare(
      'SELECT id, name AS title FROM courses WHERE (user_id IS NULL OR user_id = ?) AND name LIKE ? LIMIT 10',
    )
    .all(req.userId, `%${q}%`)
    .map((r) => ({ id: r.id, title: r.title, type: 'course' }));

  const books = db
    .prepare('SELECT id, title FROM books WHERE title LIKE ? LIMIT 10')
    .all(`%${q}%`)
    .map((r) => ({ id: r.id, title: r.title, type: 'book' }));

  const market = db
    .prepare('SELECT id, title FROM market_items WHERE title LIKE ? LIMIT 10')
    .all(`%${q}%`)
    .map((r) => ({ id: r.id, title: r.title, type: 'market' }));

  res.json({ courses, books, market });
});

module.exports = router;
