const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.post('/login', (req, res) => {
  const { studentId, password } = req.body || {};
  if (!studentId || !password) {
    return res.status(400).json({ error: '请输入学号和密码' });
  }
  const sid = String(studentId).trim();
  const user = db.prepare('SELECT * FROM users WHERE student_id = ?').get(sid);
  if (!user || user.password !== String(password)) {
    return res.status(400).json({ error: '学号或密码错误（演示账号 20210001 / 123456）' });
  }
  const token = uuidv4();
  db.prepare('INSERT INTO sessions (token, user_id) VALUES (?, ?)').run(token, user.id);
  res.json({
    token,
    user: {
      id: user.id,
      studentId: user.student_id,
      name: user.name,
      major: user.major || '',
      grade: user.grade || '',
    },
  });
});

router.post('/logout', authRequired, (req, res) => {
  db.prepare('DELETE FROM sessions WHERE token = ?').run(req.token);
  res.json({ ok: true });
});

router.get('/me', authRequired, (req, res) => {
  res.json({ user: req.user });
});

module.exports = router;
