const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const rows = db.prepare('SELECT * FROM clubs ORDER BY event_date').all();
  const registered = new Set(
    db
      .prepare('SELECT club_id FROM club_registrations WHERE user_id = ?')
      .all(req.userId)
      .map((r) => r.club_id),
  );
  const counts = {};
  for (const r of db.prepare('SELECT club_id, COUNT(*) AS c FROM club_registrations GROUP BY club_id').all()) {
    counts[r.club_id] = r.c;
  }
  res.json({
    clubs: rows.map((c) => ({
      id: c.id,
      name: c.name,
      description: c.description,
      eventDate: c.event_date,
      location: c.location,
      maxMembers: c.max_members,
      registeredCount: counts[c.id] || 0,
      registered: registered.has(c.id),
    })),
  });
});

router.get('/:id', authRequired, (req, res) => {
  const c = db.prepare('SELECT * FROM clubs WHERE id = ?').get(req.params.id);
  if (!c) return res.status(404).json({ error: '活动不存在' });
  const count = db
    .prepare('SELECT COUNT(*) AS c FROM club_registrations WHERE club_id = ?')
    .get(c.id).c;
  const registered = !!db
    .prepare('SELECT 1 FROM club_registrations WHERE user_id = ? AND club_id = ?')
    .get(req.userId, c.id);
  res.json({
    club: {
      id: c.id,
      name: c.name,
      description: c.description,
      eventDate: c.event_date,
      location: c.location,
      maxMembers: c.max_members,
      registeredCount: count,
      registered,
    },
  });
});

router.post('/:id/register', authRequired, (req, res) => {
  const c = db.prepare('SELECT * FROM clubs WHERE id = ?').get(req.params.id);
  if (!c) return res.status(404).json({ error: '活动不存在' });
  const count = db
    .prepare('SELECT COUNT(*) AS c FROM club_registrations WHERE club_id = ?')
    .get(c.id).c;
  if (count >= c.max_members) return res.status(400).json({ error: '报名已满' });
  try {
    db.prepare('INSERT INTO club_registrations (user_id, club_id) VALUES (?, ?)').run(
      req.userId,
      c.id,
    );
  } catch {
    return res.status(400).json({ error: '已报名' });
  }
  res.json({ ok: true });
});

module.exports = router;
