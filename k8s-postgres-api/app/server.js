const express = require('express');
const {Pool} = require('pg');
const app = express();

const PORT = 8080;
const PG_HOST = process.env.PG_HOST || 'postgres-service';
const PG_USER = process.env.PG_USER || 'postgres';
const PG_PASSWORD = process.env.PG_PASSWORD || 'postgres';
const PG_DB = process.env.PG_DB || 'testdb';

const pool = new Pool({
    host: PG_HOST,
    user: PG_USER,
    password: PG_PASSWORD,
    database: PG_DB,
    port: 5432
});

app.get('/', async(req, res) => {
    try{
        const result = await pool.query('SELECT NOW() as now');
        res.json({message: 'API running on kubernetes', time: result.rows[0].now});
    }catch(err){
        res.status(500).json({error: err.message});
    }
});

app.get('/users', async (req, res) => {
    try{
        const result = await pool.query('SELECT * FROM users');
        res.json(result.rows)
    }catch(err){
        res.status(500).json({error: err.message});
    }
});

app.listen(PORT, () => console.log(`API listening on port ${PORT}`));