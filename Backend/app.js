const bodyParser = require('body-parser');
const cors = require('cors');
const express = require('express');
const logger = require('morgan');

const questionRoutes = require('./routes/splash');
const appointmentRoutes = require('./routes/splash');

const app = express();

app.use(cors());
app.use(logger('dev'));
app.use(bodyParser.urlencoded({ encoded: false }));
app.use(bodyParser.json());
app.use('/questions', )

module.exports = app;