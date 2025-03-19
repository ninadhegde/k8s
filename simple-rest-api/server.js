const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

// Middleware to parse JSON requests
app.use(bodyParser.json());

// GET endpoint
app.get('/api/data', (req, res) => {
  const data = {
    message: 'This is a GET request response',
    timestamp: new Date().toISOString(),
  };
  res.json(data);
});

// POST endpoint
app.post('/api/data', (req, res) => {
  const receivedData = req.body;
  console.log('Received data:', receivedData); // Log the received data

  const response = {
    message: 'Data received successfully',
    received: receivedData,
    timestamp: new Date().toISOString(),
  };

  res.json(response);
});

// Start the server
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
