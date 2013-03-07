/*jslint sloppy: true, devel: true */
/*global window, cordova, $, document */

var onDeviceReady = function () {
	var authenticated = false;

	/* Authenticate player */
	$('#auth').on('click', function () {
		window.GameCenter.authenticatePlayer(function (player) {
			authenticated = player.authenticated;

			$('#player .authenticated').html('Player auth status: ' + player.authenticated);
			$('#player .playerId').html(player.playerID);
			$('#player .alias').html(player.alias);
		}, function (message) {
			// Error...
			alert("Couldn't log in! Try again...");
		});
	});

	/* Report a high score */
	$('#report-score').on('click', function () {
		if (authenticated === false) {
			alert('Authenticate first!');
			return;
		}

		var category,
			score;

		category = 'test';
		score = parseInt($('#score-value').val(), 10);

		window.GameCenter.reportScore(score, category, function (scoreObject) {
			// Success!
			alert('Successfully reported your score of ' + score + ' in category "' + category + '"');
		}, function (message) {
			// Error...
			console.log("Couldn't send score. Keep the score object and try to re-send it later.");
			console.log(message);
		});
	});

	/* Show "native" leaderboard */
	$('#show-leaderboard').on('click', function () {
		if (authenticated === false) {
			alert('Authenticate first!');
			return;
		}

		var category = 'test',
			time = "day";

		window.GameCenter.showLeaderboard(category, time, function () {
			// Success!
			console.log("Successfully displayed native leaderboard!");
		}, function (message) {
			// Error...
			console.log("Couldn't show leaderboard");
		});
	});

	/* Get leaderboard scores programmatically */
	$('#get-scores').on('click', function () {
		if (authenticated === false) {
			alert('Authenticate first!');
			return;
		}

		var category = 'test';

		window.GameCenter.retrieveScores(category, function (scores) {
			// Success!
			console.log(scores);
		}, function (message) {
			// Error...
			console.log("Couldn't retrieve scores: " + message);
		});
	});

	/* Show "native" achievement UI */
	$('#show-achievements').on('click', function () {
		window.GameCenter.showAchievements(function () {
			// Success!
			console.log("Successfully displayed achievements UI");
		}, function (message) {
			// Error...
			console.log("Couldn't show achievements: " + message);
		});
	});

	/* Request a turn-based Game Center match */
	$('#request-match').on('click', function () {
		if (authenticated === false) {
			alert('Authenticate first!');
			return;
		}

		window.GameCenter.requestMatch(function () {
			// Success!
			console.log("Successfully requested match");
		}, function (message) {
			// Error...
			console.log("Couldn't request match: " + message);
		});
	});
};

document.addEventListener('deviceready', onDeviceReady, false);