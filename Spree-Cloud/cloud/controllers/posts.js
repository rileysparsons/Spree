var Post = Parse.Object.extend('Post');

var _ = require("underscore");

// Display all posts.
exports.posts = function(req, res) {

  console.log("called" + req.query.q);
  var user = Parse.User.current();

  if (user){
    if (req.query.q){

      var toLowerCase = function(w) { return w.toLowerCase(); }
      var searchTerms = req.query.q.split(" ");
      searchTerms = _.map(searchTerms, toLowerCase);
      var stopWords = ["the", "in", "and"];
      searchTerms = _.filter(searchTerms, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });



      console.log("terms: "+ searchTerms);
      user.fetch().then(function(fetchedUser){
          var query = new Parse.Query(Post);
          query.descending('createdAt');
          query.equalTo("network", fetchedUser.get("network"));
          query.doesNotExist("removed");
          query.equalTo("sold", false);
          query.equalTo("expired", false);
          query.containsAll("keywords", searchTerms);
          query.find().then(function(results) {
            // console.log('results' + results[0].get("sold"));
            res.render('posts', {
              posts: results,
              query: req.query.q 
            });
          },
          function() {
            res.send(500, 'Failed loading posts');
          });
      }, function(error){
            res.send(500, 'Failed loading user');
      });
    } else {
      user.fetch().then(function(fetchedUser){
          var query = new Parse.Query(Post);
          query.descending('createdAt');
          query.equalTo("network", fetchedUser.get("network"));
          query.doesNotExist("removed");
          query.equalTo("sold", false);
          query.equalTo("expired", false);
          query.find().then(function(results) {
            console.log('results' + results[0].get("sold"));
            res.render('posts', {
              posts: results
            });
          },
          function() {
            res.send(500, 'Failed loading posts');
          });
      }, function(error){
            res.send(500, 'Failed loading user');
      });
    }
  } else {
      res.redirect('/login');
  }
};

// Display all posts.
exports.index = function(req, res) {
  res.render('main', { 
     
  });
};

exports.detail = function(req, res) {

    var postQuery = new Parse.Query(Post);
    var foundPost;
    postQuery.get(req.params.id).then(function(post) {
      foundPost = post;
      res.render('detail', {
        post: foundPost
      });
    },
    function() {
      res.send(500, 'Failed finding the specified post to show');
    });

};

exports.logout = function(req, res) {
  Parse.User.logOut().then(function(b){
    res.redirect("/login");
  });
};

