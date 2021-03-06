//
//  SHVisitorHuddleViewController.h
//  Study Huddle
//
//  Created by Jose Rafael Leon Bigio Anton on 7/13/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SHHuddlePortraitView.h"

@class Student;

@interface SHVisitorHuddleViewController : UIViewController
@property (strong,nonatomic) SHHuddlePortraitView* profileImage;


- (id)initWithHuddle:(PFObject *)aHuddle;
- (void)setHuddle:(PFObject *)aHuddle;


@end
