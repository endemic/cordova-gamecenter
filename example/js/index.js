/*jslint sloppy: true, devel: true */
/*global window, cordova, $, document */

var onDeviceReady = function () {
	var authenticated = false,
		data = {
			score: 0
		};

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

	/* Show all current matches */
	$('#show-matches').on('click', function () {
		if (authenticated === false) {
			alert('Authenticate first!');
			return;
		}

		window.GameCenter.loadMatches(function (matches) {
			// Success!
			console.log(matches);

			/* match status codes:
				GKTurnBasedMatchStatusUnknown = 0,
				GKTurnBasedMatchStatusOpen = 1,
				GKTurnBasedMatchStatusEnded = 2,
				GKTurnBasedMatchStatusMatching = 3
			 */

			var output = $('#matches');

			output.html('');

			matches.forEach(function (match) {
				// Get participants
				var participants;
				if (match.participants[0].alias === undefined) {
					match.participants[0].alias = "Waiting for player";
				}
				if (match.participants[1].alias === undefined) {
					match.participants[1].alias = "Waiting for player";
				}
				participants = match.participants[0].alias + ' vs. ' + match.participants[1].alias;

				output.append('<div><span class="match" style="border: 1px solid #ccc;" data-id="' + match.matchId + '">' + participants + '</span><a data-id="' + match.matchId + '" class="close">X</a></div>');
			});
		}, function (message) {
			// Error...
			console.log("Couldn't load matches: " + message);
		});
	});

	/* Load a particular match */
	$('#matches').on('click', '.match', function () {
		if (authenticated === false) {
			alert('Authenticate first!');
			return;
		}

		var matchId = $(this).data('id');

		window.GameCenter.loadMatch(matchId, function (data) {
			// Success!
			console.log("Match data:");
			console.log(data.score);
		}, function (message) {
			// Error...
			console.log("Couldn't load matches: " + message);
		});
	});

	/* Delete a particular match */
	$('#matches').on('click', '.close', function () {
		if (authenticated === false) {
			alert('Authenticate first!');
			return;
		}

		var matchId = $(this).data('id');

		window.GameCenter.quitMatch(matchId, function (data) {
			// Success!
			console.log("Ended match.");
		}, function (message) {
			// Error...
			console.log("Couldn't quit the match.");
		});
	});

    /* Take a turn */
    $('#advance-turn').on('click', function () {
        if (authenticated === false) {
			alert('Authenticate first!');
			return;
		}

		// Arbitrary data that gets sent to Game Center as a representation
		// of the player's actions
		data.score += 1;

		window.GameCenter.advanceTurn(data, function () {
			// Success!
			console.log("Successfully advanced the match!");
		}, function (message) {
			// Error...
			console.log("Couldn't advance match: " + message);
		});
    });

    // auto login
    $('#auth').trigger('click');
};

document.addEventListener('deviceready', onDeviceReady, false);