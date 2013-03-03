/*jslint sloppy: true */
/*global window, cordova */

// Game Center Resources
// http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/GameKit_Guide/Introduction/Introduction.html

// Test account: nd_test@test.com
// Password: G4m3c3nt3r

window.GameCenter = {};

/**
 * @description Presents a login modal
 */
window.GameCenter.authenticatePlayer = function (success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "authenticateLocalPlayer", []);	// success callback, error callback, class, method, args
};

/**
 * @description Callback for the async login process; overwrite with your own logic
 */
window.GameCenter.playerWasAuthenticated = function (player) {
    console.log("Player successfully authenticated.");
    console.log(player);
    
    // "player" var is an object which looks like this:
    // { authenticated: true, playerID: XXXXX, alias: "Public display name" }
};

/**
 * @description Send a leaderboard high score for a particular category
 */
window.GameCenter.reportScore = function (score, category, success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "reportScore", [score, category]);	// success callback, error callback, class, method, args
};

/**
 * @description Retrieve all high scores in a particular category
 */
window.GameCenter.retrieveScores = function (category, success, error) {
    cordova.exec(success, error, "GameCenterPlugin", "retrieveScoresForCategory", [category]);	// success callback, error callback, class, method, args
};

/*
METHODS
=======

authenticatePlayer()

reportScore(score, category)
getScores(category)

reportAchievement(id, percentComplete)
getAchievements()
*/