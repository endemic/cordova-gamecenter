//
//  GameCenterPlugin.h
//
//  Created by Nathan Demick on 3/1/13.
//  Copyright (c) 2013 Ganbaru Games. All rights reserved.
//

#import <Cordova/CDV.h>
#import <GameKit/GameKit.h>

@interface GameCenterPlugin : CDVPlugin <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GKTurnBasedEventHandlerDelegate, GKTurnBasedMatchmakerViewControllerDelegate>
{
    // Store saved Game Center achievement progress
    NSMutableDictionary *achievementsDictionary;
    GKTurnBasedMatch *currentTurnBasedMatch;
    NSArray *currentMatches;
}

@property (nonatomic, readwrite, retain) NSMutableDictionary *achievementsDictionary;
@property (nonatomic, readwrite, retain) GKTurnBasedMatch *currentTurnBasedMatch;
@property (nonatomic, readwrite, retain) NSArray *currentMatches;

// Game Center methods
- (void)authenticateLocalPlayer;

// Leaderboards
- (void)reportScore:(CDVInvokedUrlCommand *)command;
- (void)showLeaderboard:(CDVInvokedUrlCommand *)command;
- (void)retrieveScores:(CDVInvokedUrlCommand *)command;

// Achievements
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier;  // helper method
- (void)reportAchievement:(CDVInvokedUrlCommand *)command;
- (void)retrieveAchievement:(CDVInvokedUrlCommand *)command;
- (void)showAchievements:(CDVInvokedUrlCommand *)command;

// Matchmaking
- (void)requestMatch:(CDVInvokedUrlCommand *)command;
- (void)loadMatches:(CDVInvokedUrlCommand *)command;
- (void)loadMatchWithId:(CDVInvokedUrlCommand *)command;
- (void)advanceTurn:(CDVInvokedUrlCommand *)command;
- (void)endMatch:(CDVInvokedUrlCommand *)command;

@end