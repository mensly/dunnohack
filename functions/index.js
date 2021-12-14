const cors = require('cors')({origin: true});
const admin = require("firebase-admin");
const functions = require("firebase-functions");
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

/**
 * Create a random code for a game
 * @return {string} code
 **/
function generateCode() {
  const chars = [..."BCDFGHJKLMNPQRSTVWXYZ"];
  return [...Array(4)].map((i) => chars[Math.random() * chars.length|0]).join``;
}

/**
 * @param {string} code Code to check
 * @return {boolean} true if this code is already in use
 **/
async function isOccupied(code) {
  const docRef = db.collection("games").doc(code);
  const doc = await docRef.get();
  if (!doc.exists) {
    return false;
  }
  const ONE_DAY = 1000 * 60 * 60 * 24;
  return doc.get("lastAlive") > Date.now() - ONE_DAY * 3;
}

exports.startGame = functions.https.onRequest(async (req, res) => {
  cors(req, res, async () => {

  let code;
  do {
    code = generateCode();
  } while (await isOccupied(code));
  await db.collection("games")
    .doc(code)
    .set({host: req.body.hostId, lastAlive: Date.now(), answers: []});
  res.json({code: code});

  });
});
