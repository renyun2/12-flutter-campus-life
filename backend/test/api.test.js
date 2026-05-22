const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, '..', 'data', 'campus-test.db');

before(() => {
  if (fs.existsSync(dbPath)) fs.unlinkSync(dbPath);
  process.env.CAMPUS_DB_PATH = dbPath;
});

after(() => {
  try {
    const db = require('../src/db');
    db.close();
  } catch (_) {}
  if (fs.existsSync(dbPath)) fs.unlinkSync(dbPath);
});

test('seed creates demo user and courses', () => {
  const { seed } = require('../src/seed');
  seed();
  const db = require('../src/db');
  const user = db.prepare('SELECT * FROM users WHERE student_id = ?').get('20210001');
  assert.ok(user);
  const courses = db.prepare('SELECT COUNT(*) AS c FROM courses').get().c;
  assert.ok(courses >= 5);
  const pois = db.prepare('SELECT COUNT(*) AS c FROM map_pois').get().c;
  assert.ok(pois >= 10);
});
