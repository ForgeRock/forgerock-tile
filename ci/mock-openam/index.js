var express = require('express');
var bodyParser = require('body-parser');
var app = express();

var reqs = [];

app.get('/reqs', function(req, res) {
   res.status(200).json(reqs);
   reqs = [];
});

app.use(bodyParser.json());
app.use(function(req, res, next) {
    reqs.push({
        path: req.path,
        headers: req.headers,
        body: req.body,
        method: req.method
    });
    next();
});

app.get('/openam/json/serverinfo/*', function(req, res) {
    res.status(200).json({
        cookieName: "test-cookie-name"
    });
});

app.post('/openam/json/test-realm/authenticate', function(req, res) {
    res.status(200).json({
        tokenId: "test-token-id"
    });
});

app.get('/openam/json/test-realm/agents', function(req, res) {
    res.status(200).json({
        result: [],
        resultCount: 0
    });
});

app.post('/openam/json/test-realm/agents', function(req, res) {
    res.sendStatus(200);
});

app.delete('/openam/json/test-realm/agents/:id', function(req, res) {
    res.sendStatus(200);
});

app.listen(process.env.PORT || 3000);

