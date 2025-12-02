const express = require('express');
const redis = require('redis');
const app = express();
const PORT = 5001;

const REDIS_HOST = process.env.REDIS_HOST || 'redis-service';
const client = redis.createClient({socket: {host: REDIS_HOST, port: 6379}});
client.connect().then(() => console.log("Connected to Redis"));

app.get('/visits', async(req, res) => {
    const visits = await client.incr('visits');
    res.json({visits});
});

app.listen(PORT, () => console.log(`Data service running port : , ${PORT}`));