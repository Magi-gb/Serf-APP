const fs = require("fs");
const path = require("path");

const dataDir = path.join(__dirname, "..", "data");
const dbPath = path.join(dataDir, "db.json");
const seedPath = path.join(dataDir, "seed.json");

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, data) {
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}

function ensureDb() {
  if (!fs.existsSync(dbPath)) {
    resetDb();
  }
}

function readDb() {
  ensureDb();
  return readJson(dbPath);
}

function writeDb(db) {
  writeJson(dbPath, db);
}

function resetDb() {
  if (!fs.existsSync(seedPath)) {
    throw new Error("Seed data not found");
  }
  writeJson(dbPath, readJson(seedPath));
}

module.exports = {
  readDb,
  writeDb,
  resetDb,
  dbPath,
  seedPath
};
