// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
	response.success("Hello world!");
});

Parse.Cloud.define("sendMail", function(request, response) {
	var Mandrill = require('mandrill');
	Mandrill.initialize('BSEMYtGxtM8LySaUgQsFUA');

	Mandrill.sendEmail({
		message: {
			text: request.params.text,
			subject: request.params.subject,
			from_email: request.params.fromEmail,
			from_name: request.params.fromName,
			to: [
			{
				email: request.params.toEmail,
				name: request.params.toName
			}
			]
			},
			async: true
		},{
			success: function(httpResponse) {
			console.log(httpResponse);
			response.success("Email sent!");
		},
		error: function(httpResponse) {
			console.error(httpResponse);
			response.error("Uh oh, something went wrong");
		}
	});
});

Parse.Cloud.onCreate(Parse.User, function(request, response) {
	if (true) {
		response.success;
	} else {
		response.success;	
	}
});