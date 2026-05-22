const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const card = db.prepare('SELECT balance FROM campus_cards WHERE user_id = ?').get(req.userId);
  const days = Number(req.query.days || 7);
  const since = new Date();
  since.setDate(since.getDate() - days);
  const txs = db
    .prepare(
      'SELECT * FROM card_transactions WHERE user_id = ? AND created_at >= ? ORDER BY created_at DESC',
    )
    .all(req.userId, since.toISOString());
  res.json({
    balance: card?.balance ?? 0,
    transactions: txs.map((t) => ({
      id: t.id,
      amount: t.amount,
      type: t.type,
      description: t.description,
      createdAt: t.created_at,
    })),
  });
});

router.post('/topup', authRequired, (req, res) => {
  const amount = Number(req.body?.amount);
  if (!amount || amount <= 0) return res.status(400).json({ error: '请输入有效充值金额' });

  const tx = db.transaction(() => {
    const existing = db.prepare('SELECT balance FROM campus_cards WHERE user_id = ?').get(req.userId);
    if (existing) {
      db.prepare('UPDATE campus_cards SET balance = balance + ? WHERE user_id = ?').run(
        amount,
        req.userId,
      );
    } else {
      db.prepare('INSERT INTO campus_cards (user_id, balance) VALUES (?, ?)').run(
        req.userId,
        amount,
      );
    }
    db.prepare(
      'INSERT INTO card_transactions (id, user_id, amount, type, description) VALUES (?, ?, ?, ?, ?)',
    ).run(uuidv4(), req.userId, amount, 'topup', '在线充值');
  });
  tx();
  const balance = db.prepare('SELECT balance FROM campus_cards WHERE user_id = ?').get(req.userId)
    .balance;
  res.json({ ok: true, balance });
});

module.exports = router;
