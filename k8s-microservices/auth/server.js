const express = require('express');
const app = express();
const PORT = 5000;

app.get('/login', (req, res) => {
    res.json({message: 'User authenticated successfully'})
});

app.listen(PORT, () => console.log(`Auth service running on ${PORT}`));