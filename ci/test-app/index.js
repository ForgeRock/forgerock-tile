var express = require('express');
var app = express();

app.get('/services', function(req, res) {
    res.status(200).json(JSON.parse(process.env.VCAP_SERVICES));
});

app.listen(process.env.PORT || 3000);