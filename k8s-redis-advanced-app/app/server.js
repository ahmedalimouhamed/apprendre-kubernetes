const express = require('express');
const redis = require('redis');
const app = express();

const PORT = 8080;
const REDIS_HOST = process.env.REDIS_HOST || 'redis-service';
const REDIS_PORT = process.env.REDIS_PORT || 6379

const client = redis.createClient({
    socket: {host: REDIS_HOST, port: REDIS_PORT}
});

client.connect()
    .then(() => console.log('connected to Redis'))
    .catch(err => console.error("X Redis connection error : ", err));
    
app.get('/', async(req, res) => {
    try{
        const visits = await client.incr('visits');
        res.send(`
            <h2>Node.js + Redis on kubernetes</h2>    
            <p>Visits: ${visits}</p>
        `);
    }catch(err){
        res.status(500).send("Error connecting to redis : "+ err.message);
    }
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`))