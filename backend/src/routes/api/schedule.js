const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

function mapCourse(row) {
  return {
    id: row.id,
    name: row.name,
    teacher: row.teacher,
    room: row.room,
    dayOfWeek: row.day_of_week,
    startPeriod: row.start_period,
    endPeriod: row.end_period,
    weeks: JSON.parse(row.weeks_json || '[]'),
    homework: row.homework || '',
  };
}

router.get('/', authRequired, (req, res) => {
  const rows = db
    .prepare(
      'SELECT * FROM courses WHERE user_id IS NULL OR user_id = ? ORDER BY day_of_week, start_period',
    )
    .all(req.userId);
  res.json({ courses: rows.map(mapCourse) });
});

router.get('/:id', authRequired, (req, res) => {
  const row = db
    .prepare('SELECT * FROM courses WHERE id = ? AND (user_id IS NULL OR user_id = ?)')
    .get(req.params.id, req.userId);
  if (!row) return res.status(404).json({ error: '课程不存在' });
  res.json({ course: mapCourse(row) });
});

router.post('/', authRequired, (req, res) => {
  const { name, teacher, room, dayOfWeek, startPeriod, endPeriod, weeks, homework } = req.body || {};
  if (!name || dayOfWeek == null || startPeriod == null) {
    return res.status(400).json({ error: '请填写课程名称、星期和节次' });
  }
  const id = uuidv4();
  db.prepare(
    `INSERT INTO courses (id, user_id, name, teacher, room, day_of_week, start_period, end_period, weeks_json, homework)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
  ).run(
    id,
    req.userId,
    String(name).trim(),
    String(teacher || '').trim(),
    String(room || '').trim(),
    Number(dayOfWeek),
    Number(startPeriod),
    Number(endPeriod || startPeriod),
    JSON.stringify(weeks || []),
    String(homework || '').trim(),
  );
  const row = db.prepare('SELECT * FROM courses WHERE id = ?').get(id);
  res.status(201).json({ course: mapCourse(row) });
});

module.exports = router;
