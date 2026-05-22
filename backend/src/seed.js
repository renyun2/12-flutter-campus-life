const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const db = require('./db');

const mockDir = path.join(__dirname, '..', '..', 'mobile', 'assets', 'mock');

function readJson(name) {
  return JSON.parse(fs.readFileSync(path.join(mockDir, name), 'utf8'));
}

function seed() {
  const userCount = db.prepare('SELECT COUNT(*) AS c FROM users').get().c;
  if (userCount > 0) {
    console.log('Database already seeded, skip.');
    return;
  }

  const courses = readJson('courses.json');
  const grades = readJson('grades.json');
  const books = readJson('books.json');
  const canteens = readJson('canteens.json');
  const dishes = readJson('dishes.json');
  const clubs = readJson('clubs.json');
  const pois = readJson('map_pois.json');
  const market = readJson('market.json');

  const userId = uuidv4();
  const tx = db.transaction(() => {
    db.prepare(
      'INSERT INTO users (id, student_id, name, password, major, grade) VALUES (?, ?, ?, ?, ?, ?)',
    ).run(userId, '20210001', '张三', '123456', '计算机科学与技术', '2021级');

    db.prepare('INSERT INTO campus_cards (user_id, balance) VALUES (?, ?)').run(userId, 128.5);

    for (const c of courses) {
      db.prepare(
        `INSERT INTO courses (id, user_id, name, teacher, room, day_of_week, start_period, end_period, weeks_json, homework)
         VALUES (?, NULL, ?, ?, ?, ?, ?, ?, ?, ?)`,
      ).run(
        c.id,
        c.name,
        c.teacher,
        c.room,
        c.dayOfWeek,
        c.startPeriod,
        c.endPeriod,
        JSON.stringify(c.weeks || []),
        c.homework || '',
      );
    }

    for (const g of grades) {
      db.prepare(
        'INSERT INTO grades (id, user_id, term, course_name, score, credit) VALUES (?, ?, ?, ?, ?, ?)',
      ).run(uuidv4(), userId, g.term, g.courseName, g.score, g.credit);
    }

    for (const b of books) {
      db.prepare(
        'INSERT INTO books (id, title, author, location, available, total, summary) VALUES (?, ?, ?, ?, ?, ?, ?)',
      ).run(b.id, b.title, b.author, b.location, b.available, b.total, b.summary || '');
    }

    for (const c of canteens) {
      db.prepare('INSERT INTO canteens (id, name) VALUES (?, ?)').run(c.id, c.name);
    }

    for (const d of dishes) {
      db.prepare(
        'INSERT INTO dishes (id, canteen_id, name, price, nutrition_json, rating, description) VALUES (?, ?, ?, ?, ?, ?, ?)',
      ).run(
        d.id,
        d.canteenId,
        d.name,
        d.price,
        JSON.stringify(d.nutrition || {}),
        d.rating || 4,
        d.description || '',
      );
    }

    db.prepare(
      "INSERT INTO card_transactions (id, user_id, amount, type, description, created_at) VALUES (?, ?, ?, ?, ?, datetime('now', '-1 day'))",
    ).run(uuidv4(), userId, -12.5, 'consume', '第一食堂午餐');
    db.prepare(
      "INSERT INTO card_transactions (id, user_id, amount, type, description, created_at) VALUES (?, ?, ?, ?, ?, datetime('now', '-3 day'))",
    ).run(uuidv4(), userId, -8, 'consume', '超市购物');
    db.prepare(
      "INSERT INTO card_transactions (id, user_id, amount, type, description, created_at) VALUES (?, ?, ?, ?, ?, datetime('now', '-10 day'))",
    ).run(uuidv4(), userId, 100, 'topup', '在线充值');

    for (const lf of [
      { type: 'lost', title: '丢失黑色钱包', description: '图书馆三楼', status: 'open' },
      { type: 'found', title: '捡到校园卡', description: '体育馆门口', status: 'open' },
    ]) {
      db.prepare(
        'INSERT INTO lost_found (id, user_id, type, title, description, status) VALUES (?, ?, ?, ?, ?, ?)',
      ).run(uuidv4(), userId, lf.type, lf.title, lf.description, lf.status);
    }

    for (const c of clubs) {
      db.prepare(
        'INSERT INTO clubs (id, name, description, event_date, location, max_members) VALUES (?, ?, ?, ?, ?, ?)',
      ).run(c.id, c.name, c.description, c.eventDate, c.location, c.maxMembers || 50);
    }

    for (const p of pois) {
      db.prepare('INSERT INTO map_pois (id, name, lat, lng, description) VALUES (?, ?, ?, ?, ?)').run(
        p.id,
        p.name,
        p.lat,
        p.lng,
        p.description,
      );
    }

    for (const m of market) {
      db.prepare(
        'INSERT INTO market_items (id, user_id, title, price, category, description, seller_name) VALUES (?, ?, ?, ?, ?, ?, ?)',
      ).run(m.id, userId, m.title, m.price, m.category, m.description || '', m.sellerName || '张三');
    }

    for (const msg of [
      { title: '欢迎使用校园生活', body: '登录成功，祝您学习愉快！', type: 'system' },
      { title: '借阅提醒', body: '《算法导论》将于 7 天后到期', type: 'library' },
    ]) {
      db.prepare(
        'INSERT INTO messages (id, user_id, title, body, type) VALUES (?, ?, ?, ?, ?)',
      ).run(uuidv4(), userId, msg.title, msg.body, msg.type);
    }
  });
  tx();

  console.log('Seeded demo user: 20210001 / 123456');
}

if (require.main === module) seed();

module.exports = { seed };
