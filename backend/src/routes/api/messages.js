const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const rows = db
    .prepare('SELECT * FROM messages WHERE user_id = ? ORDER BY created_at DESC')
    .all(req.userId);
  res.json({
    messages: rows.map((m) => ({
      id: m.id,
      title: m.title,
      body: m.body,
      type: m.type,
      read: !!m.read_flag,
      createdAt: m.created_at,
    })),
  });
});

router.patch('/:id/read', authRequired, (req, res) => {
  db.prepare('UPDATE messages SET read_flag = 1 WHERE id = ? AND user_id = ?').run(
    req.params.id,
    req.userId,
  );
  res.json({ ok: true });
});

module.exports = router;
