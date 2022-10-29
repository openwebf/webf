const express = require('express');
const path = require('path');
const app = express();
const cookieParser = require('cookie-parser')

app.use(cookieParser());
app.use('/public', express.static(path.join(__dirname, '../.specs/')))
app.use('/public/assets', express.static(path.join(__dirname, '../assets/')))

app.get('/set_cookie', (req, res) => {
    const query = req.query;
    const options = query.options || {};
    res.cookie(query.key, query.value, options);
    res.end();
});

app.get('/verify_cookie', (req, res) => {
    const query = req.query;
    const value = req.cookies[query.id];
    if (value == null) return res.end('invalid');
    return res.end(value === query.value ? 'true' : 'false');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Mock HTTP server listening on port ${port}`)
});
