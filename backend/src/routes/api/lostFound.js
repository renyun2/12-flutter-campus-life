const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const type = req.query.type;
  let rows;
  if (type) {
    rows = db
      .prepare('SELECT * FROM lost_found WHERE type = ? ORDER BY created_at DESC')
      .all(String(type));
  } else {
    rows = db.prepare('SELECT * FROM lost_found ORDER BY created_at DESC').all();
  }
  res.json({
    items: rows.map((r) => ({
      id: r.id,
      userId: r.user_id,
      type: r.type,
      title: r.title,
      description: r.description,
      status: r.status,
      imageUrl: r.image_url,
      createdAt: r.created_at,
    })),
  });
});

router.post('/', authRequired, (req, res) => {
  const { type, title, description, imageUrl } = req.body || {};
  if (!type || !title) return res.status(400).json({ error: '请填写类型和标题' });
  const id = uuidv4();
  db.prepare(
    'INSERT INTO lost_found (id, user_id, type, title, description, image_url) VALUES (?, ?, ?, ?, ?, ?)',
  ).run(
    id,
    req.userId,
    String(type),
    String(title).trim(),
    String(description || '').trim(),
    String(imageUrl || '').trim(),
  );
  res.status(201).json({ id });
});

router.patch('/:id/status', authRequired, (req, res) => {
  const { status } = req.body || {};
  if (!['open', 'resolved'].includes(status)) {
    return res.status(400).json({ error: '状态无效' });
  }
  const item = db.prepare('SELECT * FROM lost_found WHERE id = ?').get(req.params.id);
  if (!item) return res.status(404).json({ error: '记录不存在' });
  db.prepare('UPDATE lost_found SET status = ? WHERE id = ?').run(status, req.params.id);
  res.json({ ok: true });
});

module.exports = router;
