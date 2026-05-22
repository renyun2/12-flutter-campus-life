const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();
const MAX_BORROW = 5;

function mapBook(row) {
  return {
    id: row.id,
    title: row.title,
    author: row.author,
    location: row.location,
    available: row.available,
    total: row.total,
    summary: row.summary || '',
  };
}

router.get('/', authRequired, (req, res) => {
  const q = String(req.query.q || '').trim();
  let rows;
  if (q) {
    rows = db
      .prepare('SELECT * FROM books WHERE title LIKE ? OR author LIKE ? ORDER BY title')
      .all(`%${q}%`, `%${q}%`);
  } else {
    rows = db.prepare('SELECT * FROM books ORDER BY title').all();
  }
  const borrowed = db
    .prepare("SELECT COUNT(*) AS c FROM borrow_records WHERE user_id = ? AND status = 'active'")
    .get(req.userId).c;
  res.json({ books: rows.map(mapBook), borrowedCount: borrowed, maxBorrow: MAX_BORROW });
});

router.get('/records', authRequired, (req, res) => {
  const rows = db
    .prepare(
      `SELECT br.*, b.title, b.author FROM borrow_records br
       JOIN books b ON b.id = br.book_id
       WHERE br.user_id = ? ORDER BY br.borrowed_at DESC`,
    )
    .all(req.userId);
  res.json({
    records: rows.map((r) => ({
      id: r.id,
      bookId: r.book_id,
      title: r.title,
      author: r.author,
      borrowedAt: r.borrowed_at,
      dueDate: r.due_date,
      renewed: !!r.renewed,
      status: r.status,
    })),
  });
});

router.get('/:id', authRequired, (req, res) => {
  const row = db.prepare('SELECT * FROM books WHERE id = ?').get(req.params.id);
  if (!row) return res.status(404).json({ error: '图书不存在' });
  res.json({ book: mapBook(row) });
});

router.post('/:id/borrow', authRequired, (req, res) => {
  const book = db.prepare('SELECT * FROM books WHERE id = ?').get(req.params.id);
  if (!book) return res.status(404).json({ error: '图书不存在' });
  if (book.available <= 0) return res.status(400).json({ error: '暂无馆藏' });

  const active = db
    .prepare("SELECT COUNT(*) AS c FROM borrow_records WHERE user_id = ? AND status = 'active'")
    .get(req.userId).c;
  if (active >= MAX_BORROW) return res.status(400).json({ error: `借书上限 ${MAX_BORROW} 本` });

  const due = new Date();
  due.setDate(due.getDate() + 30);
  const id = uuidv4();
  const tx = db.transaction(() => {
    db.prepare('UPDATE books SET available = available - 1 WHERE id = ?').run(book.id);
    db.prepare(
      'INSERT INTO borrow_records (id, user_id, book_id, due_date) VALUES (?, ?, ?, ?)',
    ).run(id, req.userId, book.id, due.toISOString().slice(0, 10));
  });
  tx();
  res.status(201).json({ ok: true, recordId: id, dueDate: due.toISOString().slice(0, 10) });
});

router.post('/records/:id/renew', authRequired, (req, res) => {
  const record = db
    .prepare("SELECT * FROM borrow_records WHERE id = ? AND user_id = ? AND status = 'active'")
    .get(req.params.id, req.userId);
  if (!record) return res.status(404).json({ error: '借阅记录不存在' });
  if (record.renewed) return res.status(400).json({ error: '每本书仅可续借一次' });

  const due = new Date(record.due_date);
  due.setDate(due.getDate() + 30);
  db.prepare('UPDATE borrow_records SET due_date = ?, renewed = 1 WHERE id = ?').run(
    due.toISOString().slice(0, 10),
    record.id,
  );
  res.json({ ok: true, dueDate: due.toISOString().slice(0, 10) });
});

module.exports = router;
