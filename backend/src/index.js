const express = require('express');
const cors = require('cors');
const { seed } = require('./seed');

const authRoutes = require('./routes/api/auth');
const scheduleRoutes = require('./routes/api/schedule');
const gradesRoutes = require('./routes/api/grades');
const libraryRoutes = require('./routes/api/library');
const canteenRoutes = require('./routes/api/canteen');
const campusCardRoutes = require('./routes/api/campusCard');
const lostFoundRoutes = require('./routes/api/lostFound');
const clubsRoutes = require('./routes/api/clubs');
const mapRoutes = require('./routes/api/map');
const marketRoutes = require('./routes/api/market');
const messagesRoutes = require('./routes/api/messages');
const searchRoutes = require('./routes/api/search');

seed();

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors({ origin: true }));
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true }));

app.use('/api/auth', authRoutes);
app.use('/api/schedule', scheduleRoutes);
app.use('/api/grades', gradesRoutes);
app.use('/api/library', libraryRoutes);
app.use('/api/canteen', canteenRoutes);
app.use('/api/campus-card', campusCardRoutes);
app.use('/api/lost-found', lostFoundRoutes);
app.use('/api/clubs', clubsRoutes);
app.use('/api/map', mapRoutes);
app.use('/api/market', marketRoutes);
app.use('/api/messages', messagesRoutes);
app.use('/api/search', searchRoutes);

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Campus backend running at http://localhost:${PORT}`);
    console.log(`API base: http://localhost:${PORT}/api`);
  });
}

module.exports = app;
