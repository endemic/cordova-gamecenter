/* Copyright (c) 2013 Nathan Demick

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */

#import <Cordova/CDV.h>
#import <GameKit/GameKit.h>

@interface GameCenterPlugin : CDVPlugin <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GKTurnBasedEventHandlerDelegate, GKTurnBasedMatchmakerViewControllerDelegate>
{
    // Store saved Game Center achievement progress
    NSMutableDictionary *achievementsDictionary;
    NSMutableArray *currentMatches;
}

@property (nonatomic, readwrite, retain) NSMutableDictionary *achievementsDictionary;
@property (nonatomic, readwrite, retain) NSMutableArray *currentMatches;

// Game Center methods
- (void)authenticateLocalPlayer:(CDVInvokedUrlCommand *)command;

// Leaderboards
- (void)reportScore:(CDVInvokedUrlCommand *)command;
- (void)showLeaderboard:(CDVInvokedUrlCommand *)command;
- (void)retrieveScores:(CDVInvokedUrlCommand *)command;

// Achievements
- (void)loadAchievements:(CDVInvokedUrlCommand *)command;
- (void)reportAchievement:(CDVInvokedUrlCommand *)command;
- (void)showAchievements:(CDVInvokedUrlCommand *)command;

// Turn-based matches
- (void)requestMatch:(CDVInvokedUrlCommand *)command;
- (void)loadMatches:(CDVInvokedUrlCommand *)command;
- (void)loadMatch:(CDVInvokedUrlCommand *)command;
- (void)advanceTurn:(CDVInvokedUrlCommand *)command;
- (void)quitMatch:(CDVInvokedUrlCommand *)command;
- (void)endMatch:(CDVInvokedUrlCommand *)command;
- (void)removeMatch:(CDVInvokedUrlCommand *)command;
- (GKTurnBasedMatch *)findMatchWithId:(NSString *)matchId;    // helper method

@end