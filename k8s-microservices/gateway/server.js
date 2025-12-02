const express = require('express');
const axios = require('axios');
const app = express();
const PORT = 8080;

const AUTH_URL = "http://auth-service:5000";
const DATA_URL = "http://data-service:5001";

app.get('/',(req, res) => res.send('<h2>API Gateway running on kubernetes</h2>'));

app.get('/login', async(req, res) => {
    const {data} = await axios.get(`${AUTH_URL}/login`);
    res.json(data); 
});

app.get('/visits', async(req, res) => {
    const {data} = await axios.get(`${DATA_URL}/visits`);
    res.json(data);
})

app.listen(PORT, () => console.log(`Gateway running on ${PORT}`))