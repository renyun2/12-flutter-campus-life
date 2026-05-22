const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const rows = db
    .prepare('SELECT * FROM grades WHERE user_id = ? ORDER BY term DESC, course_name')
    .all(req.userId);
  const terms = [...new Set(rows.map((r) => r.term))];
  res.json({
    terms,
    grades: rows.map((r) => ({
      id: r.id,
      term: r.term,
      courseName: r.course_name,
      score: r.score,
      credit: r.credit,
    })),
  });
});

router.get('/term/:termId', authRequired, (req, res) => {
  const term = decodeURIComponent(req.params.termId);
  const rows = db
    .prepare('SELECT * FROM grades WHERE user_id = ? AND term = ? ORDER BY course_name')
    .all(req.userId, term);
  if (rows.length === 0) return res.status(404).json({ error: '学期不存在' });

  let totalCredit = 0;
  let weighted = 0;
  for (const r of rows) {
    totalCredit += r.credit;
    weighted += r.score * r.credit;
  }
  const gpa = totalCredit > 0 ? weighted / totalCredit / 25 : 0;

  res.json({
    term,
    gpa: Math.round(gpa * 100) / 100,
    totalCredit,
    items: rows.map((r) => ({
      id: r.id,
      courseName: r.course_name,
      score: r.score,
      credit: r.credit,
    })),
  });
});

module.exports = router;
