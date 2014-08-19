//
//  SHCache.h
//  Study Huddle
//
//  Created by Jason Dimitriou on 7/29/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface SHCache : NSObject

+ (id)sharedCache;

- (void)reloadCacheCurrentUser;

#pragma mark - Huddle
- (void)setHuddles:(NSArray *)huddles;
- (NSArray *)huddles;
- (void)setAttributesForHuddle:(PFObject *)huddle;
- (void)setAttributesForHuddle:(PFObject *)huddle withMembers:(NSArray *)members;
- (void)setNewHuddle:(PFObject *)huddle;
- (void)setNewHuddle:(PFObject *)huddle withMembers:(NSArray *)members;
- (PFObject *)objectForHuddle:(PFObject *)huddle;
- (NSArray *)membersForHuddle:(PFObject *)huddle;
- (NSArray *)resourceCategoriesForHuddle:(PFObject *)huddle;
- (NSArray *)chatCategoriessForHuddle:(PFObject *)huddle;
- (void)setHuddleStudying:(PFObject *)huddle;


#pragma mark - Class
- (void)setClasses:(NSArray *)huddleClasses;
- (NSArray *)classes;
- (void)setAttributesForClass:(PFObject *)huddleClass;
- (void)setNewClass:(PFObject *)huddleClass;
- (void)leaveClass:(PFObject *)huddleClass;
- (PFObject *)objectForClass:(PFObject *)huddleClass;
- (NSArray *)studentsForClass:(PFObject *)huddleClass;
- (NSArray *)huddlesForClass:(PFObject *)huddleClass;
- (NSArray *)chatCategoriessForClass:(PFObject *)aClass;


#pragma mark - User
- (void)setStudyFriends:(NSArray *)friends;
- (NSArray *)studyFriends;
- (void)setAttributesForUser:(PFUser *)user;
- (void)setNewStudyFriend:(PFUser *)user;
- (PFUser *)objectForUser:(PFUser *)user;

#pragma mark - Study
- (void)setStudyLogs:(NSArray *)logs;
- (NSArray *)studyLogs;
- (void)setAttributesForStudyLog:(PFObject *)log;
- (void)setNewStudyLog:(PFObject *)studyLog;
- (PFObject *)objectForStudyLog:(PFObject *)log;

#pragma mark - Notifications
- (void)setNotifications:(NSArray *)notifications;
- (NSArray *)notifications;
- (void)setAttributesForNotification:(PFObject *)notification;
- (void)setNewNotification:(PFObject *)notification;
- (NSArray *)reloadNotifications;

#pragma mark - Requests
- (void)setRequests:(NSArray *)requests;
- (NSArray *)requests;
- (void)setAttributesForRequest:(PFObject *)request;
- (void)setNewRequest:(PFObject *)request;
- (NSArray *)reloadRequests;





@end
