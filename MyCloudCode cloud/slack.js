exports.postNotificationToSlack = function(message) {
	var username = 'Parse.com (vCinity LIVE)'
	Parse.Cloud.httpRequest({
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			url: 'https://hooks.slack.com/services/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',
			body: {
				"text": message,
				'username': username,
				'icon_url': 'https://pbs.twimg.com/profile_images/474688991472918528/5Sl9Ols6.jpeg'
			},
			success: function(httpResponse) {
				console.log("Email send response: " + httpResponse.text);
			},
			error: function(httpResponse) {
				console.error("Email send Error: " + httpResponse.text);
			}
		});
};