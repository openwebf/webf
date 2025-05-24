const express = require('express');
const path = require('path');
const app = express();
const cookieParser = require('cookie-parser');
const multer = require('multer');
const bodyParser = require('body-parser');

// Set up multer storage for FormData file uploads
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.use(cookieParser());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
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
    // This route intentionally doesn't respond
});

app.get('/verify_cookie', (req, res) => {
    const query = req.query;
    const value = req.cookies[query.id];
    if (value == null) return res.end('invalid');
    return res.end(value === query.value ? 'true' : 'false');
});

// Endpoint to handle FormData uploads with verification
app.post('/upload', upload.any(), (req, res) => {
    try {
        // Extract form fields from request body
        const formFields = req.body;
        
        // Extract files from the request
        const files = req.files || [];
        
        // Prepare response with detailed information for verification
        const response = {
            success: true,
            message: 'FormData received and validated',
            fields: formFields,
            files: files.map(file => ({
                fieldname: file.fieldname,
                originalname: file.originalname,
                mimetype: file.mimetype,
                size: file.size,
                // Provide a preview of file content for verification
                // (limited to first 100 chars to avoid huge responses)
                contentPreview: file.buffer.toString('utf-8').substring(0, 100)
            }))
        };
        
        res.json(response);
    } catch (error) {
        console.error('Error processing FormData:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
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