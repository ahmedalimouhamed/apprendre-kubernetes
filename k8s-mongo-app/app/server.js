const express = require('express');
const mongoose = require('mongoose');
const app = express();

const PORT = 8080;
const MONGO_URL = process.env.MONGO_URL || 'mongodb://mongo-service:27017/test-k8-db';

mongoose.connect(MONGO_URL)
    .then(() => console.log('Connecte to MongoDB'))
    .catch(err => console.error('X MongoDB connection error : ', err));


app.get('/', (req, res) => {
    res.send('<h2>Hello from Node.js + MongoDB (Kubernates)!</h2>');
});

app.get('/status', async(req, res) => {
    const status = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
    res.json({database: status});
})

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));