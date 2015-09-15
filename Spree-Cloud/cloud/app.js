var express = require('express');

var app = express();

/**
 * Global app configuration section
 */
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request bodu

var clientId = '2928';
var clientSecret = 'YVZtkzqsFLHxke8hneCWXHZvxUs7rTtS';
var authorizeUrl = 'https://api.venmo.com/v1/oauth/authorize?client_id=' + clientId + '&scope=make_payments%20access_profile&response_type=code';
var accessTokenUrl = 'https://api.venmo.com/v1/oauth/access_token';
var paymentUrl = 'https://api.venmo.com/v1/payments';


console.log("HERE");

app.get('/venmo/authorize', function(req, res) {
  return res.redirect(authorizeUrl);
});

app.get('/venmo/oauth', function(req, res) {
  if (!req.query.code) {
    return res.send('no code provided');
  }
  request.post({
  url: accessTokenUrl,
  form: {
    client_id: clientId,
    client_secret: clientSecret,
    code: req.query.code
  }
}, function(err, response, body) {
	return res.render('auth');
  });
}); // end '/oauth' route

