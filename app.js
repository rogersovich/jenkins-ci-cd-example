// app.js
const express = require('express');
const app = express();
const port = 3000; // You can choose any available port

app.get('/', (req, res) => {
  res.json({
    message: "Hello Gais",
    name: "Bimbim Squat", 
  });
});

app.listen(port, () => {
  console.log(`Express app listening at http://localhost:${port}`);
});