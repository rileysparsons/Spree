exports.sendApp = function(req, res) {
  console.log(req.body.username);
  console.log(req.body.password);

   var phone = form.phone.value;
                var linkData = {
                    tags: [],
                    channel: 'Website',
                    feature: 'TextMeTheApp',
                    data: {
                        "foo": "bar"
                    }
                };
                var options = {};
                var callback = function(err, result) {
                    if (err) {
                        alert("Sorry, something went wrong.");
                    }
                    else {
                        alert("SMS sent!");
                    }
                };
                branch.sendSMS(phone, linkData, options, callback);
                form.phone.value = "";
  
  // works!
};