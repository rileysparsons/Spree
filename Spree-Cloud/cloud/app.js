var express = require('express');
var moment = require('moment');
var _ = require("underscore");
var cookieSession = require('parse-express-cookie-session');

var app = express();

var indexController = require('cloud/controllers/index.js');
var postsController = require('cloud/controllers/posts.js');
var loginController = require('cloud/controllers/login.js');

Parse.initialize("F2jyNwFtpy0O9ufRLxBnMQWRtGQju6kV0JEbUZlf", "qNFqw64sHNQSlCODNr9RQehwkj3p9mToFHLhFfS7");

/*r
 * Global app configuration section
 */
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine

app.use(express.cookieParser('secret key'));

app.use(cookieSession({ cookie: { maxAge: 3600000 }}));

app.use(express.bodyParser());    // Middleware for reading request body

app.use(express.methodOverride());


app.locals.formatTime = function(time) {
  return moment(time).format('MMMM Do YYYY, h:mm a');
};

// Generate a snippet of the given text with the given length, rounded up to the
// nearest word.
app.locals.snippet = function(text, length) {
  if (text.length < length) {
    return text;
  } else {
    var regEx = new RegExp("^.{" + length + "}[^ ]*");
    return regEx.exec(text)[0] + "...";
  }
};

// Show all posts on homepage
app.get('/login', loginController.showLogin);
app.post('/login', loginController.submitLogin);

app.get ('/logout', postsController.logout);

app.get('/', postsController.index);
app.post('/', indexController.sendApp);
app.get('/posts', postsController.posts);
app.get('/posts/:id', postsController.detail);





app.listen();


