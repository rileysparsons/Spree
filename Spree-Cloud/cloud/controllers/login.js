exports.submitLogin = function(req, res) {
  console.log(req.body.username);
  console.log(req.body.password);

  Parse.User.logIn(req.body.username, req.body.password).then(function(){

        res.redirect('/posts');

  }, function (error) {
        console.log(error);
        res.redirect('/login');
  });

  // works!
};

exports.showLogin = function(req, res){
  res.render('login', {

  });
};
