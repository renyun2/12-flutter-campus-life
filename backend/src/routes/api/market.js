const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

function mapItem(row, extras = {}) {
  return {
    id: row.id,
    userId: row.user_id,
    title: row.title,
    price: row.price,
    category: row.category,
    description: row.description || '',
    sellerName: row.seller_name,
    createdAt: row.created_at,
    ...extras,
  };
}

router.get('/', authRequired, (req, res) => {
  const q = String(req.query.q || '').trim();
  let rows;
  if (q) {
    rows = db
      .prepare('SELECT * FROM market_items WHERE title LIKE ? ORDER BY created_at DESC')
      .all(`%${q}%`);
  } else {
    rows = db.prepare('SELECT * FROM market_items ORDER BY created_at DESC').all();
  }
  const favs = new Set(
    db
      .prepare('SELECT item_id FROM market_favorites WHERE user_id = ?')
      .all(req.userId)
      .map((r) => r.item_id),
  );
  res.json({ items: rows.map((r) => mapItem(r, { favorited: favs.has(r.id) })) });
});

router.get('/history', authRequired, (req, res) => {
  const rows = db
    .prepare(
      `SELECT mi.* FROM market_history mh
       JOIN market_items mi ON mi.id = mh.item_id
       WHERE mh.user_id = ? ORDER BY mh.viewed_at DESC LIMIT 20`,
    )
    .all(req.userId);
  res.json({ items: rows.map((r) => mapItem(r)) });
});

router.get('/:id', authRequired, (req, res) => {
  const row = db.prepare('SELECT * FROM market_items WHERE id = ?').get(req.params.id);
  if (!row) return res.status(404).json({ error: '商品不存在' });
  db.prepare('INSERT INTO market_history (user_id, item_id) VALUES (?, ?)').run(
    req.userId,
    row.id,
  );
  const favorited = !!db
    .prepare('SELECT 1 FROM market_favorites WHERE user_id = ? AND item_id = ?')
    .get(req.userId, row.id);
  res.json({ item: mapItem(row, { favorited }) });
});

router.post('/', authRequired, (req, res) => {
  const { title, price, category, description } = req.body || {};
  if (!title || price == null) return res.status(400).json({ error: '请填写标题和价格' });
  const user = db.prepare('SELECT name FROM users WHERE id = ?').get(req.userId);
  const id = uuidv4();
  db.prepare(
    'INSERT INTO market_items (id, user_id, title, price, category, description, seller_name) VALUES (?, ?, ?, ?, ?, ?, ?)',
  ).run(
    id,
    req.userId,
    String(title).trim(),
    Number(price),
    String(category || '其他').trim(),
    String(description || '').trim(),
    user.name,
  );
  res.status(201).json({ id });
});

router.post('/:id/favorite', authRequired, (req, res) => {
  const item = db.prepare('SELECT id FROM market_items WHERE id = ?').get(req.params.id);
  if (!item) return res.status(404).json({ error: '商品不存在' });
  try {
    db.prepare('INSERT INTO market_favorites (user_id, item_id) VALUES (?, ?)').run(
      req.userId,
      item.id,
    );
  } catch {
    return res.status(400).json({ error: '已收藏' });
  }
  res.json({ ok: true });
});

router.delete('/:id/favorite', authRequired, (req, res) => {
  db.prepare('DELETE FROM market_favorites WHERE user_id = ? AND item_id = ?').run(
    req.userId,
    req.params.id,
  );
  res.json({ ok: true });
});

router.post('/:id/report', authRequired, (req, res) => {
  const item = db.prepare('SELECT title FROM market_items WHERE id = ?').get(req.params.id);
  if (!item) return res.status(404).json({ error: '商品不存在' });
  db.prepare(
    'INSERT INTO messages (id, user_id, title, body, type) VALUES (?, ?, ?, ?, ?)',
  ).run(
    uuidv4(),
    req.userId,
    '举报已提交',
    `您举报了商品「${item.title}」，我们会尽快处理。`,
    'system',
  );
  res.json({ ok: true });
});

module.exports = router;
