// TEST

require('cloud/app.js');

Parse.Cloud.job("updateOldPosts", function(request, status) {

Parse.Cloud.useMasterKey()
var post = Parse.Object.extend("Post");
var query = new Parse.Query(post);

var day = new Date();
day.setDate(day.getDate());

query.greaterThan("expirationDate", day);
query.equalTo("expired",false);
query.equalTo("sold", false);
query.equalTo("keep", false);

    query.find({
            success:function(results) {
		console.log(results.length);
                for (var i = 0, len = results.length; i < len; i++) {
                    var result = results[i];
		                // result.set("expired", true);
                    // console.log("Updated: "+result);
                    // var installation = Parse.Object.extend("Installation");
                    // var query =  new Parse.Query(installation);
                    // query.equalTo("user", result.get("user"));
                    // Parse.Push.send({
                    //     where: query,
                    //     data: {
                    //          alert: "One of your posts has expired. You can repost it through the More section.",
                    //          post: result.id
                    //       }
                    //     }, { success: function() { 
                    //       // success!
                    //       }, error: function(err) { 
                    //         console.log(err);
                    //       }
                    // });
                }
                    status.success("Updated successfully.");  

                Parse.Object.saveAll(results,{
                success: function(list) {
                  // All the objects were saved.
                  response.success("ok " );  //saveAll is now finished and we can properly exit with confidence :-)
                },
                error: function(error) {
                  // An error occurred while saving one of the objects.
                  response.error("failure on saving list ");
                },
                });

            },
            error: function(error) {
            status.error("Uh oh, something went wrong.");
            console.log("Failed!");         
            }
    });
});


Parse.Cloud.job("addLocation", function(request, status) {
	// Parse.Cloud.useMasterKey()
	var post = Parse.Object.extend("Post");
	var query = new Parse.Query(post).limit(1000);

	query.find({
		success:function(results) {
			console.log("results: " + results.length);

			var gp = new Parse.GeoPoint({
                latitude: 37.3492,
                longitude: -121.9381                   
            });

			for (var i = 0, len = results.length; i < len; i++) {
                    var result = results[i];
		            result.set("location", gp);
            }

            Parse.Object.saveAll(results,{
			    success: function(list) {
			      // All the objects were saved.
			      status.success("ok ");  //saveAll is now finished and we can properly exit with confidence :-)
			    },
			    error: function(error) {
			      // An error occurred while saving one of the objects.
			      status.error("failure on saving list ");
			    },
		  	});

		},  error: function(error) {
	            status.error("Uh oh, something went wrong." + error.message);
	            console.log("Failed!");         
            }
    });

});

var _ = require("underscore");
Parse.Cloud.beforeSave("Post", function(request, response) {
    var post = request.object;

    var toLowerCase = function(w) { return w.toLowerCase(); };

    var words = post.get("userDescription").split(" ");

    _.each(post.get("title").split(" "), function(keyword){
    	words.push(keyword);
    });

// Will update to accomodate PostType Pointer
// Will add more fields to add to words
	console.log("1");
	console.log(words);
	
    words = _.map(words, toLowerCase);
    console.log("2");
	console.log(words);
    var stopWords = ["the", "in", "and"];
    words = _.filter(words, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
    console.log("3");
	console.log(words);
    post.set("keywords", words);


    var PostType = request.object.get("typePointer");
	var query = new Parse.Query("PostType");
	console.log("id" + PostType.get("objectId"));
	PostType.fetch();
	PostType.increment("count");
	PostType.save(null, {
	  success: function(point) {
	    // Saved successfully
	  },
	  error: function(point, error) {
	    // The save failed.
	    // error is a Parse.Error with an error code and description.
	  }
	});
    response.success();
});

//save handlers
Parse.Cloud.beforeSave(Parse.User, function(request, response) {
    var user = request.object;
    Parse.Cloud.useMasterKey()
 //    if (user.get("password")){
	//     var email = request.object.get("email");
	//     var dot = ".";

	//     if ((email.indexOf(dot)>-1)) {
	//         var network = email.substring(email.lastIndexOf("@")+1,email.lastIndexOf(dot));
	//         user.set("network", network);
	//         // console.log("Updated: "+user+network);
	//     }
	// } else {
	// 	user.set("network", "DEMO");
	// }
	response.success();
});


Parse.Cloud.job("updateExistingUsers", function(request, status) {
	Parse.Cloud.useMasterKey()
	var query = new Parse.Query(Parse.User).limit(1000);
	query.find({
		success:function(results) {
			console.log(results.length)
			for (var i = 0, len = results.length; i < len; i++) {
                    var result = results[i];
		            result.set("username", result.get("email"));
            }
            Parse.Object.saveAll(results,{
			    success: function(list) {
			      // All the objects were saved.
			      status.success("ok ");  //saveAll is now finished and we can properly exit with confidence :-)
			    },
			    error: function(error) {
			      // An error occurred while saving one of the objects.
			      status.error("failure on saving list ");
			    },
		  	});

		},  error: function(error) {
	            status.error("Uh oh, something went wrong.");
	            console.log("Failed!");         
            }
    });

});

Parse.Cloud.job("setCampus", function(request, status) {

	Parse.Cloud.useMasterKey()
	var query = new Parse.Query(Parse.User).limit(1000);

	function getLastIndex(arr, val) {
	    var lastIndex = 0;
	    for(var i = 0, len = arr.length; i < len; i++)
	        if (arr[i] === val)
	            lastIndex = i;
	    		
	    return lastIndex;
	}


	var campusList = [];
	var campusQuery = new Parse.Query("Campus").limit(1000);
	campusQuery.find({
		success:function(results) {
			campusList = results;
		}
	});

	query.find({
		success:function(results) {
			console.log(results.length)
			var network;
			for (var i = 0, len = results.length; i < len; i++) {
                    var result = results[i];
		            var email = result.get("email");
		            console.log(email);
		            var indexOfLastDot = getLastIndex(email, ".");
		            network = email.substring(email.lastIndexOf("@")+1,indexOfLastDot);
		            for (var n = 0, count = campusList.length; n < count; n++){
		            	if (campusList[n].get("networkCode") == network){
		            		result.set("campus", campusList[n]);
		            		break;
		            	}
		           }
		     }
 
            Parse.Object.saveAll(results,{
			    success: function(list) {
			      // All the objects were saved.
			      status.success("ok ");  //saveAll is now finished and we can properly exit with confidence :-)
			    },
			    error: function(error) {
			      // An error occurred while saving one of the objects.
			      status.error("failure on saving list ");
			    },
		  	});

		},  error: function(error) {
	            status.error("Uh oh, something went wrong.");
	            console.log("Failed!");         
            }
    });
});

Parse.Cloud.job("setType", function(request, status) {

	Parse.Cloud.useMasterKey()
	var query = new Parse.Query("Post").limit(1000);
	var typeList = [];
	var typeQuery = new Parse.Query("PostType").limit(1000);
	typeQuery.find({
		success:function(results) {
			typeList = results;
		}
	});

	query.find({
		success:function(results) {
			console.log(results.length)
			for (var i = 0, len = results.length; i < len; i++) {
                    var result = results[i];
		            var type = result.get("type");
		            for (var n = 0, count = typeList.length; n < count; n++){
		            	if (typeList[n].get("type") == type){
		            		result.set("typePointer", typeList[n]);
		            		break;
		            	}
		           }
		     }
 
            Parse.Object.saveAll(results,{
			    success: function(list) {
			      // All the objects were saved.
			      status.success("ok ");  //saveAll is now finished and we can properly exit with confidence :-)
			    },
			    error: function(error) {
			      // An error occurred while saving one of the objects.
			      status.error("failure on saving list ");
			    },
		  	});

		},  error: function(error) {
	            status.error("Uh oh, something went wrong.");
	            console.log("Failed!");         
            }
    });
});

Parse.Cloud.job("keepExistingPosts", function(request, status){
	Parse.Cloud.useMasterKey();
	var query = new Parse.Query("Post").limit(100);

	query.find({success:function(results){
		for (var i = 0, len = results.length; i < len; i++) {
            var result = results[i];
            result.set("keep", true);
      	}
      	Parse.Object.saveAll(results,{
      		success: function(list) {
			      // All the objects were saved.
			      status.success("ok ");  //saveAll is now finished and we can properly exit with confidence :-)
			    },
			    error: function(error) {
			      // An error occurred while saving one of the objects.
			      status.error("failure on saving list ");
			    },
      	});

	}, error: function(error){
		status.error("Uh oh, something went wrong.");
	    console.log("Failed!"); 
	}

	});

});



