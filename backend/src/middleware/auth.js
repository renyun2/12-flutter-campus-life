const db = require('../db');

function authRequired(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: '未登录' });

  const session = db.prepare('SELECT user_id FROM sessions WHERE token = ?').get(token);
  if (!session) return res.status(401).json({ error: '登录已过期' });

  const user = db
    .prepare('SELECT id, student_id, name, major, grade FROM users WHERE id = ?')
    .get(session.user_id);
  if (!user) return res.status(401).json({ error: '用户不存在' });

  req.token = token;
  req.userId = user.id;
  req.user = {
    id: user.id,
    studentId: user.student_id,
    name: user.name,
    major: user.major || '',
    grade: user.grade || '',
  };
  next();
}

module.exports = { authRequired };
