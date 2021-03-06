//
//  SHProfileSegmentViewController.h
//  Study Huddle
//
//  Created by Jason Dimitriou on 6/14/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZNSegmentedControl.h"
#import <Parse/Parse.h>
@class SHProfileViewController;

@interface SHProfileSegmentViewController : UIViewController <DZNSegmentedControlDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) DZNSegmentedControl *control;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic,strong) UIScrollView* parentScrollView;



- (id)initWithStudent:(PFUser *)student;

- (void)setStudent:(PFUser *)aSegStudent;
- (BOOL)loadStudentDataRefresh:(BOOL)refresh;
- (void)currentStudy:(PFObject *)study;

-(float)getOccupatingHeight;

@end


#define huddleCellHeight 70.0f
#define studentCellHeight 70.0f
#define classCellHeight 50.0f
#define requestsCellHeight 50.0f
