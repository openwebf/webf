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
    const cookieOptions = {
        ...options
    };
    if (options.expires) {
        cookieOptions['expires'] = new Date(options.expires);
    }
    res.cookie(query.key, query.value, cookieOptions);
    res.end();
});

app.get('/unresponse', (req, res) => {

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

const staticApp = express();
staticApp.use(cookieParser());
staticApp.use('/public', express.static(path.join(__dirname, '../.specs/')))
staticApp.use('/public/assets', express.static(path.join(__dirname, '../assets/')))
staticApp.listen(parseInt(port) + 1, () => {
    console.log(`Separate HTTP server listening on port ${parseInt(port) + 1}`)
});
