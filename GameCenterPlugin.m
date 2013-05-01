//
//  GameCenterPlugin.m
//
//  Created by Nathan Demick on 3/1/13.
//  Copyright (c) 2013 Ganbaru Games. All rights reserved.
//

#import "GameCenterPlugin.h"
#import <Cordova/CDV.h>

@implementation GameCenterPlugin

@synthesize achievementsDictionary, currentMatches;

#pragma mark -
#pragma mark Game Center methods

/*
- (void)pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticationChanged)
                                                 name:GKPlayerAuthenticationDidChangeNotificationName
                                               object:nil];
}
*/

- (void)authenticateLocalPlayer:(CDVInvokedUrlCommand *)command
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

    // iOS5-style auth
    [localPlayer authenticateWithCompletionHandler: ^(NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        }
        else if (localPlayer.isAuthenticated)
        {
            NSDictionary *playerInfo = [NSDictionary dictionaryWithObjectsAndKeys:localPlayer.playerID, @"playerId",
                                                                               localPlayer.alias, @"alias",
                                                                               [NSNumber numberWithBool:localPlayer.isAuthenticated], @"authenticated", nil];
            
            // Tell the current class to respond to turn based event notifications
            [GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = self;
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playerInfo];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wasn't able to authenticate. Try logging in using the Game Center app."];
        }
        
        // Send the result
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark -
#pragma mark Leaderboards

/* Send a high score */
- (void)reportScore:(CDVInvokedUrlCommand *)command
{
    int64_t score = (int64_t)[command.arguments objectAtIndex:0];
    NSString *category = [command.arguments objectAtIndex:1];
    
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    
    //NSLog(@"Trying to send score %lld for category %@", score, category);
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        CDVPluginResult *result = nil;
        NSDictionary *highScore = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:score], @"score", category, @"category", nil];
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:highScore];
        }
        
        // Send the result
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/* Show native leaderboard UI */
- (void)showLeaderboard:(CDVInvokedUrlCommand *)command
{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    
    if (leaderboardController != nil)
    {
        NSString *category = nil,
                 *timeScope = nil;
        
        if (command.arguments.count > 0)
        {
            category = [command.arguments objectAtIndex:0];
        }
        
        if (command.arguments.count > 1)
        {
            timeScope = [command.arguments objectAtIndex:1];
        }
        
        // Set category
        if (category)
        {
            leaderboardController.category = category;
        }
        
        // Set time scope - default is all time. ALL TIME.
        if ([timeScope isEqualToString:@"day"])
        {
            leaderboardController.timeScope = GKLeaderboardTimeScopeToday;
        }
        else if ([timeScope isEqualToString:@"week"])
        {
            leaderboardController.timeScope = GKLeaderboardTimeScopeWeek;
        }
        else
        {
            leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
        }
        
        leaderboardController.leaderboardDelegate = self;
        [self.viewController presentViewController:leaderboardController animated: YES completion:nil];
        
        // Send the success callback
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }
    else
    {
        // Send the error callback
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

/* Delegate callback to dismiss the native leaderboard UI */
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

/* Retrieve leaderboard scores programmatically in order to create a custom UI */
- (void)retrieveScores:(CDVInvokedUrlCommand *)command
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        NSString *category = nil,
                 *friendScope = nil,
                 *timeScope = nil;
        int range = 25;
        
        if (command.arguments.count > 0)
        {
            category = [command.arguments objectAtIndex:0];
        }
        
        if (command.arguments.count > 1)
        {
            friendScope = [command.arguments objectAtIndex:1];
        }
        
        if (command.arguments.count > 2)
        {
            timeScope = [command.arguments objectAtIndex:2];
        }
        
        if (command.arguments.count > 3)
        {
            range = [[command.arguments objectAtIndex:3] intValue];
        }
        
        // Your "default" leaderboard will be used unless you explicitly supply another one here
        if (category)
        {
            leaderboardRequest.category = category;
        }
        
        // Set global/friends scope - default is global
        if ([friendScope isEqualToString:@"friends"])
        {
            leaderboardRequest.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
        }
        else
        {
            leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        }
        
        // Set time scope - default is all time. ALL TIME.
        if ([timeScope isEqualToString:@"week"])
        {
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeWeek;
        }
        else if ([timeScope isEqualToString:@"day"])
        {
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeToday;
        }
        else
        {
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        }

        // Set the # of returned results - default is 25
        if (range > 0 && range <= 100)
        {
            leaderboardRequest.range = NSMakeRange(1, range);
        }
        
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            CDVPluginResult *result = nil;
            
            if (error != nil)
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            }
            else
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:scores];
            }
            
            // Send the result
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
}

#pragma mark -
#pragma mark Achievements

/* Load achievements and store in a local data structure */
- (void)loadAchievements:(CDVInvokedUrlCommand *)command
{
    // Load player achievements
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
        if (achievements != nil)
        {
            NSMutableArray *json = [NSMutableArray array];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd-yyyy"];
            
            // process array of achievements
            for (GKAchievement *achievement in achievements)
            {
                [achievementsDictionary setObject:achievement forKey:achievement.identifier];
                
                NSDictionary *a = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:achievement.completed], @"completed",
                                                                             achievement.identifier, @"identifier",
                                                                             [dateFormatter stringFromDate:achievement.lastReportedDate], @"lastReportedDate",
                                                                             [NSNumber numberWithDouble:achievement.percentComplete], @"percentComplete",
                                                                             [NSNumber numberWithBool:achievement.showsCompletionBanner], @"showsCompletionBanner",
                                                                             nil];
                
                [json addObject:a];
            }
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:json];
        }
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * Send a completion % for a specific achievement to Game Center
 */
- (void)reportAchievement:(CDVInvokedUrlCommand *)command
{
    NSString *identifier = @"";
    float percent = 0.0;
    
    if (command.arguments.count > 0)
    {
        identifier = [command.arguments objectAtIndex:0];
    }
    
    if (command.arguments.count > 1)
    {
        percent = [[command.arguments objectAtIndex:0] floatValue];
    }
    
    // Instantiate GKAchievement object for an achievement (set up in iTunes Connect)
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [achievementsDictionary setObject:achievement forKey:achievement.identifier];
    }
    
    achievement.percentComplete = percent;
    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/* Show the native achievement UI */
- (void)showAchievements:(CDVInvokedUrlCommand *)command
{
    GKAchievementViewController *achievementController = [[GKAchievementViewController alloc] init];
    if (achievementController != nil)
    {
        achievementController.achievementDelegate = self;
        [self.viewController presentModalViewController:achievementController animated:YES];
        
        // Send the success callback
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }
    else
    {
        // Send the error callback
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

/* Delegate callback to dismiss achievement view controller */
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Turn-based Matchmaking

/**
 * Request a Game Center match
 */
- (void)requestMatch:(CDVInvokedUrlCommand *)command
{
    int minPlayers = 2,
        maxPlayers = 2;
    
    if (command.arguments.count > 0)
    {
        minPlayers = [[command.arguments objectAtIndex:0] intValue];
    }
    
    if (command.arguments.count > 1)
    {
        maxPlayers = [[command.arguments objectAtIndex:1] intValue];
    }
    
    // Create the match request, with all the appropriate options filled in
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    request.playerGroup = 0;  // An optional property that allows you to create distinct subsets of players in your game.
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = NO;  // Change this to list matches in the view controller
    
    // Show the native UI
    [self.viewController presentViewController:mmvc animated:YES completion:nil];
    
    // Return plugin result
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

/**
 * Programmatically retrieve the list of matches & match data the local player is participating in
 */
- (void)loadMatches:(CDVInvokedUrlCommand *)command
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        CDVPluginResult *result = nil;
        
        if (matches)
        {
            self.currentMatches = [NSMutableArray arrayWithArray:matches];
            
            NSMutableDictionary *json = [NSMutableDictionary dictionary];
            NSMutableArray *playerIds = [NSMutableArray array];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd-yyyy"];
            
            for (GKTurnBasedMatch *match in matches)
            {
                NSMutableArray *participants = [NSMutableArray array];
                
                // Get participants
                for (GKTurnBasedParticipant *participant in match.participants)
                {
                    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithObjectsAndKeys:participant.playerID, @"playerId",
                                                                                               [NSNumber numberWithInt:participant.status], @"status",
                                                                                               [dateFormatter stringFromDate:participant.timeoutDate], @"timeoutDate", nil];
                    
                    [participants addObject:p];
                    
                    // Add participant to the "alias" lookup array
                    if (participant.playerID != nil && [playerIds indexOfObject:participant.playerID] == NSNotFound)
                    {
                        [playerIds addObject:participant.playerID];
                    }
                }
                
                // Get current participant
                NSMutableDictionary *currentParticipant = [NSMutableDictionary dictionaryWithObjectsAndKeys:match.currentParticipant.playerID, @"playerId",
                                                                                                           [NSNumber numberWithInt:match.currentParticipant.status], @"status",
                                                                                                           match.currentParticipant.timeoutDate, @"timeoutDate", nil];
                
                // Create a dictionary w/ relevant data
                NSMutableDictionary *m = [NSMutableDictionary dictionaryWithObjectsAndKeys:match.matchID, @"matchId",
                                                                                           [NSNumber numberWithInt:match.status], @"status",
                                                                                           participants, @"participants",
                                                                                           currentParticipant, @"currentParticipant", nil];
                
                if (match.message != nil)
                {
                    [m setObject:match.message forKey:@"message"];
                }

                [json setObject:m forKey:match.matchID];
            }
            
            // Get player aliases
            [GKPlayer loadPlayersForIdentifiers:playerIds withCompletionHandler:^(NSArray *players, NSError *error) {
                CDVPluginResult *result = nil;
                NSMutableDictionary *playerAliases = [NSMutableDictionary dictionary];
                
                if (players)
                {
                    // Create a dictionary w/ ID of player as key, alias as value
                    for (GKPlayer *player in players)
                    {
                        [playerAliases setObject:player.alias forKey:player.playerID];
                    }
                    
                    // Loop through the results array and add player aliases to match objects
                    for (NSString *key in json)
                    {
                        NSMutableDictionary *match = [json objectForKey:key];
                        
                        // Set the alias for the current participant
                        NSMutableDictionary *currentParticipant = [match objectForKey:@"currentParticipant"];
                        NSString *playerId = [currentParticipant objectForKey:@"playerId"];
                        if (playerId != nil)
                        {
                            [currentParticipant setObject:[playerAliases objectForKey:playerId] forKey:@"alias"];
                        }
                        
                        // Set the alias for all participants
                        NSMutableArray *participants = [match objectForKey:@"participants"];
                        for (NSMutableDictionary *participant in participants)
                        {
                            NSString *playerId = [participant objectForKey:@"playerId"];
                            if (playerId != nil)
                            {
                                [participant setObject:[playerAliases objectForKey:playerId] forKey:@"alias"];
                            }
                        }
                    }
                    
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
                }
                else if (error != nil)
                {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                }
                
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }];
        }
        else if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
        else
        {
            // Send back empty dictionary
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[NSDictionary dictionary]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}

/**
 * Loads match data from a specific match ID
 */
- (void)loadMatch:(CDVInvokedUrlCommand *)command
{
    NSString *matchId = @"";
    GKTurnBasedMatch *match;
    
    if (command.arguments.count > 0)
    {
        matchId = [command.arguments objectAtIndex:0];
    }
    
    match = [self findMatchWithId:matchId];
    
    if (!match)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Match not found."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        CDVPluginResult *result = nil;
        
        // Decode the match data here
        NSString *json = [[NSString alloc] initWithData:matchData encoding:NSUTF8StringEncoding];
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * Advance the turn
 */
- (void)advanceTurn:(CDVInvokedUrlCommand *)command
{
    NSString *matchId = @"";
    NSString *data = @"";
    GKTurnBasedMatch *match;
    BOOL skipNextPlayer = NO;
    
    if (command.arguments.count > 0)
    {
        matchId = [command.arguments objectAtIndex:0];
    }
    
    if ([command.arguments count] > 1)
    {
        data = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:1]];
    }
    
    if ([command.arguments count] > 2)
    {
        skipNextPlayer = (BOOL)[command.arguments objectAtIndex:2];
    }
    
    match = [self findMatchWithId:matchId];
    
    if (!match)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Match not found."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    // Determine player order
    NSMutableArray *sortedPlayerOrder = [NSMutableArray arrayWithArray:match.participants];
    
    // Remove the first player and add to the end of the array
    GKTurnBasedParticipant *p = [sortedPlayerOrder objectAtIndex:0];
    [sortedPlayerOrder removeObject:p];
    [sortedPlayerOrder addObject:p];
    
    if (skipNextPlayer)
    {
        p = [sortedPlayerOrder objectAtIndex:0];
        [sortedPlayerOrder removeObject:p];
        [sortedPlayerOrder addObject:p];
    }

    //match.message = @"Hello!";
    
    // Convert data arg to NSData
    [match endTurnWithNextParticipants:sortedPlayerOrder turnTimeout:GKTurnTimeoutDefault matchData:[data dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        
        // Send results
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * When a player wants to resign from a particular match. Method called depends on whether player is currently the active player.
 */
- (void)quitMatch:(CDVInvokedUrlCommand *)command
{
    NSString *matchId = @"";
    GKTurnBasedMatch *match;
    
    if (command.arguments.count > 0)
    {
        matchId = [command.arguments objectAtIndex:0];
    }
    
    match = [self findMatchWithId:matchId];
    
    if (!match)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Match not found."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    // Determine if you are the current player or not
    if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        NSMutableArray *sortedPlayerOrder = [NSMutableArray arrayWithArray:match.participants];
        
        // Remove the first player
        [sortedPlayerOrder removeObjectAtIndex:0];
        
        [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:sortedPlayerOrder turnTimeout:604800 matchData:match.matchData completionHandler:^(NSError *error) {
            CDVPluginResult *result = nil;
            
            if (error != nil)
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            }
            else
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            
            // Send results
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    } else {
        [match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) {
            CDVPluginResult *result = nil;
            
            if (error != nil)
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            }
            else
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            
            // Send results
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
}

/**
 * When the game ends "normally"
 */
- (void)endMatch:(CDVInvokedUrlCommand *)command
{
    NSString *matchId = @"";
    NSString *data = @"";
    GKTurnBasedMatch *match;
    
    if (command.arguments.count > 0)
    {
        matchId = [command.arguments objectAtIndex:0];
    }
    
    if (command.arguments.count > 1)
    {
        data = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:1]];
    }
    
    match = [self findMatchWithId:matchId];
    
    if (!match)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Match not found."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    // Convert data arg to NSData
    [match endMatchInTurnWithMatchData:[data dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        
        // Send results
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * Remove a finished game from Game Center
 */
- (void)removeMatch:(CDVInvokedUrlCommand *)command
{
    NSString *matchId = @"";
    GKTurnBasedMatch *match;

    if (command.arguments.count > 0)
    {
        matchId = [command.arguments objectAtIndex:0];
    }
    
    match = [self findMatchWithId:matchId];
    
    if (!match)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Match not found."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    [match removeWithCompletionHandler:^(NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        
        // Send results
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * Helper method which sets 'currentTurnBasedMatch' to the match with the provided matchId
 */
- (GKTurnBasedMatch *)findMatchWithId:(NSString *)matchId
{
    GKTurnBasedMatch *foundMatch = nil;
    
    // Loop through local store of match objects to find the desired one
    for (GKTurnBasedMatch *match in self.currentMatches)
    {
        if ([match.matchID isEqualToString:matchId])
        {
            foundMatch = match;
            break;
        }
    }
    
    return foundMatch;
}

#pragma mark -
#pragma mark Matchmaking delegate methods

/* Found match */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match
{
    // Store this match
    [self.currentMatches addObject:match];
    
    // Dismiss the native UI
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    // Execute a custom callback to let Javascript layer know a match was found;
    // Should pass back an object that represents the new match
    NSMutableArray *playerIds = [NSMutableArray array];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    
    NSMutableArray *participants = [NSMutableArray array];
    
    // Get participants
    for (GKTurnBasedParticipant *participant in match.participants)
    {
        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithObjectsAndKeys:participant.playerID, @"playerId",
                                  [NSNumber numberWithInt:participant.status], @"status",
                                  [dateFormatter stringFromDate:participant.timeoutDate], @"timeoutDate", nil];
        
        [participants addObject:p];
        
        // Add participant to the "alias" lookup array
        if (participant.playerID != nil && [playerIds indexOfObject:participant.playerID] == NSNotFound)
        {
            [playerIds addObject:participant.playerID];
        }
    }
    
    // Get current participant
    NSMutableDictionary *currentParticipant = [NSMutableDictionary dictionaryWithObjectsAndKeys:match.currentParticipant.playerID, @"playerId",
                                               [NSNumber numberWithInt:match.currentParticipant.status], @"status",
                                               match.currentParticipant.timeoutDate, @"timeoutDate", nil];
    
    // Create a dictionary w/ relevant data
    NSMutableDictionary *m = [NSMutableDictionary dictionaryWithObjectsAndKeys:match.matchID, @"matchId",
                              [NSNumber numberWithInt:match.status], @"status",
                              participants, @"participants",
                              currentParticipant, @"currentParticipant", nil];
    
    if (match.message != nil)
    {
        [m setObject:match.message forKey:@"message"];
    }
    
    // Get player aliases
    [GKPlayer loadPlayersForIdentifiers:playerIds withCompletionHandler:^(NSArray *players, NSError *error) {
        NSMutableDictionary *playerAliases = [NSMutableDictionary dictionary];
        
        if (players)
        {
            // Create a dictionary w/ ID of player as key, alias as value
            for (GKPlayer *player in players)
            {
                [playerAliases setObject:player.alias forKey:player.playerID];
            }
            
            // Set the alias for the current participant
            NSMutableDictionary *currentParticipant = [m objectForKey:@"currentParticipant"];
            NSString *playerId = [currentParticipant objectForKey:@"playerId"];
            if (playerId != nil)
            {
                [currentParticipant setObject:[playerAliases objectForKey:playerId] forKey:@"alias"];
            }
            
            // Set the alias for all participants
            NSMutableArray *participants = [m objectForKey:@"participants"];
            for (NSMutableDictionary *participant in participants)
            {
                NSString *playerId = [participant objectForKey:@"playerId"];
                if (playerId != nil)
                {
                    [participant setObject:[playerAliases objectForKey:playerId] forKey:@"alias"];
                }
            }
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:m options:0 error:nil];
            NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
            
            // Note that you'll have to make your "foundMatch" method parse the passed JSON string
            [self writeJavascript:[NSString stringWithFormat:@"window.GameCenter.foundMatch('%@')", jsonString]];
        }
        else if (error != nil)
        {
            [self writeJavascript:[NSString stringWithFormat:@"window.GameCenter.foundMatch('%@')", error.localizedDescription]];
        }
    }];
}

/* Cancel */
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    // Execute a custom callback
    [self writeJavascript:@"window.GameCenter.matchCancelled()"];
}

/* Fail */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    // Execute a custom callback
    [self writeJavascript:[NSString stringWithFormat:@"window.GameCenter.matchError(%@)", error.localizedDescription]];
}

/* Quit */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"playerQuitForMatch");
    
    // Execute a custom callback
    [self writeJavascript:[NSString stringWithFormat:@"window.GameCenter.playerQuit(%@)", match.matchID]];
}

#pragma mark -
#pragma mark Matchmaking events

// Player receives invitation - Push
- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite
{
    /*
     When your delegate receives this message, your game should create a new GKMatchRequest object and assign 
     the playersToInvite parameter to the match request’s playersToInvite property. Then, your game can either 
     call the GKTurnBasedMatch class method findMatchForRequest:withCompletionHandler: to find a match 
     programmatically or it can use the request to instantiate a new GKTurnBasedMatchmakerViewController
     object to show a user interface to the player.
     */
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.playersToInvite = playersToInvite;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    
    // Show native interface
    [self.viewController presentViewController:mmvc animated:YES completion:nil];
}

// Becomes player's turn - Push
// Becomes someone else's turn - Foreground
// Another player updates match data - Foreground
- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive
{
    NSLog(@"handleTurnEventForMatch");
    /*
     When your delegate receives this message, the player has accepted a push notification for a match already in progress. 
     Your game should end whatever task it was performing and switch to the match information provided by the match object.
     */
}

// Match ended - Push
- (void)handleMatchEnded:(GKTurnBasedMatch *)match
{
    NSLog(@"handleMatchEnded");
    /*
     When your delegate receives this message, it should display the match’s final results to the player and allow the 
     player the option of saving or removing the match data from Game Center.
     Also should probably allow a rematch.
     */
}

@end