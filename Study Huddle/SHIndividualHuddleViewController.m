//
//  SHProfileViewController.m
//  Study Huddle
//
//  Created by Jason Dimitriou on 6/14/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import "SHIndividualHuddleViewController.h"
#import "UIColor+HuddleColors.h"
#import "SHConstants.h"
#import "SHHuddleSegmentViewController.h"
#import "SHNewQuestionViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "SHIndividualHuddleAddViewController.h"
#import "WYPopoverController.h"
#import "SHNewResourceViewController.h"
#import "SHStudentSearchViewController.h"
#import "SHHuddleStartStudyingViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "SHStudentSearchViewController.h"
#import "SHCache.h"


#define profileImageWidth 100
#define profileImageHeight 100
#define profileImageVerticalOffsetFromTop 10

#define fullNameLabelVerticalOffsetFromPicture 5
#define fullNameWidth 400
#define fullNameHeight 20


#define hoursStudiedLabelWidth 45
#define hoursStudiedLabelHeight 30

#define sideItemDiameters 45
#define sideItemLabelsVerticalOffsetFromCircle 0
#define sideLabelsWidth 70
#define sideLabelHeight 10



#define nameLabelFont [UIFont boldSystemFontOfSize:15]

#define sideItemsFont [UIFont systemFontOfSize:7]

#define onlineOffset 40
#define topSize 170
#define locationLabelVerticalOffset 30


@interface SHIndividualHuddleViewController () <UIScrollViewDelegate, SHModalViewControllerDelegate, WYPopoverControllerDelegate, SHIndividualHuddleAddDelegate>
{
    WYPopoverController* popoverController;
}


@property (strong, nonatomic) SHHuddleSegmentViewController *segmentController;
@property UIView *segmentContainer;
@property UIScrollView* scrollView;

@property (nonatomic, strong) PFObject *indvHuddle;

@property (nonatomic, strong) UILabel* fullNameLabel;
@property (nonatomic, strong) UILabel* hoursStudiedLabel;
@property (nonatomic,strong) UILabel* startStudyingLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic,strong) UIButton* startStudyingButton;
@property BOOL isStudying;
@property int initialSection;

@property (nonatomic,strong) NSDate* lastStart;

@property (strong, nonatomic) UIBarButtonItem *addButton;
@property int topPartSize;


@end

@implementation SHIndividualHuddleViewController


- (id)init
{
    NSLog(@"normal init called");
    self = [self initWithHuddle:nil];
    
    return self;
}

- (id)initWithHuddle:(PFObject *)aHuddle
{
    NSLog(@"initWithHuddleCalled");
    self = [super init];
    if (self) {
        _indvHuddle = aHuddle;
        
        self.title = @"Huddle";
        self.tabBarItem.image = [UIImage imageNamed:@"NavProf.png"];
        
        self.initialSection = 1;
        //set up the navigation options
        //settings button
        
        //Edit Button
        self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addItem)];
        
        self.navigationItem.rightBarButtonItem = self.addButton;
        
        
    }
    return self;
}

-(id)initWithHuddle:(PFObject *)aHuddle andInitialSection:(int)section
{
    self = [self initWithHuddle:aHuddle];
    self.initialSection = section;
    return self;
}

- (void)setHuddle:(PFObject *)aHuddle
{
    
    self.indvHuddle = aHuddle;
    
    [self.segmentController setHuddle:aHuddle];
    [self.profileImage setHuddle:aHuddle];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isStudying = [self.indvHuddle[SHHuddleOnlineKey] boolValue];
    if(self.isStudying)
        self.topPartSize = topSize + onlineOffset;
    else
        self.topPartSize = topSize;
    
    [self doLayout];
    
    //get the last study date
    self.lastStart = self.indvHuddle[@"lastStart"];
    
    
    
    
    //set timer
    [NSTimer scheduledTimerWithTimeInterval:60
                                     target:self
                                   selector:@selector(updateHoursStudied)
                                   userInfo:nil
                                    repeats:YES];
    
    SHIndividualHuddleAddViewController *addVC = [[SHIndividualHuddleAddViewController alloc]init];
    [addVC.view setFrame:CGRectMake(305, 55.0, 100.0, 200.0)];
    addVC.preferredContentSize = CGSizeMake(120, 110);
    addVC.delegate = self;
    popoverController = [[WYPopoverController alloc]initWithContentViewController:addVC];
    popoverController.delegate = self;
    [WYPopoverController setDefaultTheme:[WYPopoverTheme theme]];
    
    WYPopoverBackgroundView *appearance = [WYPopoverBackgroundView appearance];
    [appearance setTintColor:[UIColor huddleSilver]];
    
    
}

-(void)doLayout
{
    
    NSArray *viewsToRemove = [self.view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.topItem.title = @"";
    
    
    //important coordinates
    float centerX = self.view.bounds.origin.x + self.view.bounds.size.width/2;
    
    float bottomOfNavBar = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    //float middleHeight = (self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)/2;
    
    //background
    UIImageView* backGroundImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"PatternBackground.png"]];
    [backGroundImg setFrame:self.view.frame];
    [self.view addSubview:backGroundImg];
    
    
    
    //set up portrait view
    CGRect profileFrame = CGRectMake(centerX-profileImageWidth/2, bottomOfNavBar + profileImageVerticalOffsetFromTop, profileImageWidth, profileImageHeight);
    
    //set up name label
    self.fullNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(centerX - fullNameWidth/2,profileFrame.origin.y + profileFrame.size.height + fullNameLabelVerticalOffsetFromPicture, fullNameWidth, fullNameHeight)];
    self.fullNameLabel.text = [self.indvHuddle[SHHuddleNameKey] uppercaseString];
    [self.fullNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.fullNameLabel setFont: nameLabelFont];
    [self.fullNameLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:self.fullNameLabel];
    
    self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(centerX - fullNameWidth/2,self.fullNameLabel.frame.origin.y + self.fullNameLabel.frame.size.height + locationLabelVerticalOffset, fullNameWidth, fullNameHeight)];
    self.locationLabel.text = [NSString stringWithFormat:@"Studying at: %@",[self.indvHuddle[SHHuddleLocationKey] uppercaseString]];
    [self.locationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.locationLabel setFont: nameLabelFont];
    [self.locationLabel setTextColor:[UIColor grayColor]];
    
    
    //set up the side items
    float leftPictureEdge = profileFrame.origin.x;
    float rightPictureEdge = leftPictureEdge + profileFrame.size.width;
    float leftMidPoint = leftPictureEdge/2-sideItemDiameters/2;
    float rightMidPoint = rightPictureEdge + leftMidPoint;
    float midYPoint = profileFrame.origin.y + profileFrame.size.height/2 - sideItemDiameters/2;
    self.startStudyingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startStudyingButton addTarget:self action:@selector(setStudy) forControlEvents:UIControlEventTouchUpInside];
    [self.startStudyingButton setFrame:CGRectMake(leftMidPoint, midYPoint, sideItemDiameters, sideItemDiameters)];
    [self.startStudyingButton setImage:[UIImage imageNamed:@"StartStudyBtn.png"] forState:UIControlStateNormal];
    //[self.startStudyingButton setBackgroundColor:[UIColor yellowColor]];
    self.startStudyingLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.startStudyingButton.frame.origin.x + self.startStudyingButton.frame.size.width/2 - sideLabelsWidth/2, self.startStudyingButton.frame.origin.y + self.startStudyingButton.frame.size.height + sideItemLabelsVerticalOffsetFromCircle, sideLabelsWidth, sideLabelHeight)];
    self.startStudyingLabel.text = @"START STUDYING";
    [self.startStudyingLabel setTextAlignment:NSTextAlignmentCenter];
    [self.startStudyingLabel setFont:sideItemsFont];
    [self.view addSubview:self.startStudyingLabel];
    
    
    UIImageView* hoursStudiedCircle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HoursStudied.png"]];
    [hoursStudiedCircle setFrame:CGRectMake(rightMidPoint, midYPoint, sideItemDiameters, sideItemDiameters)];
    [self.view addSubview:hoursStudiedCircle];
    
    //a label to display the #hours studied
    self.hoursStudiedLabel = [[UILabel alloc]initWithFrame:CGRectMake(hoursStudiedCircle.frame.origin.x + hoursStudiedCircle.frame.size.width/2 - hoursStudiedLabelWidth/2, hoursStudiedCircle.frame.origin.y + hoursStudiedCircle.frame.size.height/2 - hoursStudiedLabelHeight/2, hoursStudiedLabelWidth, hoursStudiedLabelHeight)];
    double secondsStudied = [self.indvHuddle[@"hoursStudied"] doubleValue];
    int hoursStudied = secondsStudied/3600;
    self.hoursStudiedLabel.text = [NSString stringWithFormat:@"%d",hoursStudied];
    [self.hoursStudiedLabel setTextAlignment:NSTextAlignmentCenter];
    [self.hoursStudiedLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:self.hoursStudiedLabel];
    
    UILabel* hoursStudiedBelowLabel =[[UILabel alloc]initWithFrame:CGRectMake(hoursStudiedCircle.frame.origin.x+ hoursStudiedCircle.frame.size.width/2 - sideLabelsWidth/2, hoursStudiedCircle.frame.origin.y + hoursStudiedCircle.frame.size.height + sideItemLabelsVerticalOffsetFromCircle, sideLabelsWidth, sideLabelHeight)];
    hoursStudiedBelowLabel.text = @"HOURS STUDIED";
    [hoursStudiedBelowLabel setTextAlignment:NSTextAlignmentCenter];
    [hoursStudiedBelowLabel setFont:sideItemsFont];
    //[self.startStudyingLabel setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:hoursStudiedBelowLabel];
    
    
    
    //set up scroll view
    [self setUpScrollView];
    
    
    //set up segmented view
    self.segmentContainer = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.scrollView.bounds.origin.y + self.topPartSize, self.view.frame.size.width, self.view.frame.size.height*10)];
    self.segmentContainer.backgroundColor = [UIColor clearColor];
    self.segmentController = [[SHHuddleSegmentViewController alloc]initWithHuddle:self.indvHuddle andInitialSection:self.initialSection];
    
    [self addChildViewController:self.segmentController];
    self.segmentController.view.frame = self.segmentContainer.bounds;
    self.segmentContainer.backgroundColor = [UIColor whiteColor];
    [self.segmentContainer addSubview:self.segmentController.view];
    [self.segmentController didMoveToParentViewController:self];
    self.segmentController.owner = self;
    [self.scrollView addSubview:self.segmentContainer];
    self.segmentController.parentScrollView = self.scrollView;
    
    
    self.profileImage = [[SHHuddlePortraitView alloc]initWithFrame:profileFrame];
    self.profileImage.owner = self;
    [self.profileImage setHuddle:self.indvHuddle];

    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.profileImage];
    [self.view addSubview:self.startStudyingButton];
}

-(void)setUpScrollView
{
    //[self.scrollView removeFromSuperview];
    float bottomOfNavBar = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    float viewableHeight = self.tabBarController.tabBar.frame.origin.y - self.navigationController.navigationBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height;
    CGRect scrollViewFrame = CGRectMake(self.view.bounds.origin.x, bottomOfNavBar, self.view.bounds.size.width, viewableHeight);
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    self.scrollView.delegate = self;
    CGSize sViewContentSize = scrollViewFrame.size;
    sViewContentSize.height+=(self.topPartSize);
    [self.scrollView setContentSize:sViewContentSize];
    //[self.view addSubview:self.scrollView];
}

-(void)updateHoursStudied
{
    if(self.isStudying)
    {
        NSDate* date = [NSDate date];
        NSTimeInterval diff = [date timeIntervalSinceDate:self.lastStart];
        self.lastStart = date;
        self.indvHuddle[SHHuddleLastStartKey] = date;
        NSString* hoursPrevStudied = self.indvHuddle[SHHuddleHoursStudiedKey];
        double previousTimeStudied = [hoursPrevStudied doubleValue];
        double secondsStudied = diff + previousTimeStudied;
        int hoursStudied = secondsStudied/3600;
        self.hoursStudiedLabel.text = [NSString stringWithFormat:@"%d",hoursStudied];
        
        self.indvHuddle[SHHuddleHoursStudiedKey] = [NSString stringWithFormat:@"%f",(diff+previousTimeStudied)];
        [self.indvHuddle save];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isStudying = [self.indvHuddle[SHHuddleOnlineKey] boolValue];
    //update the studying button
    if(self.isStudying)
    {
        [self.startStudyingButton setImage:[UIImage imageNamed:@"StopStudying.png"] forState:UIControlStateNormal];
        [self.startStudyingLabel setTextColor:[UIColor redColor]];
         self.startStudyingLabel.text = @"STOP STUDYING";
        [self.view addSubview:self.locationLabel];
        [self.view bringSubviewToFront:self.scrollView];
        [self.view bringSubviewToFront:self.profileImage];
        [self.view bringSubviewToFront:self.startStudyingButton];
        
    }
    else
    {
        [self.startStudyingButton setImage:[UIImage imageNamed:@"StartStudyBtn.png"] forState:UIControlStateNormal];
        [self.startStudyingLabel setTextColor:[UIColor greenColor]];
         self.startStudyingLabel.text = @"START STUDYING";
        [self.locationLabel removeFromSuperview];
        
    }
}

-(void)setStudy
{
    [self updateHoursStudied];
    if(self.isStudying)
    {
        //the user will stop their studying session
        self.indvHuddle[SHHuddleOnlineKey] = [NSNumber numberWithBool:NO];
  
        [[SHCache sharedCache] setHuddleStudying:self.indvHuddle];
        [self.indvHuddle saveInBackground];
        
        self.topPartSize = topSize;
        self.isStudying = NO;
        [self doLayout];
        [self.startStudyingButton setImage:[UIImage imageNamed:@"StartStudyBtn.png"] forState:UIControlStateNormal];
        [self.startStudyingLabel setTextColor:[UIColor greenColor]];
         self.startStudyingLabel.text = @"START STUDYING";
        //return the scroll view back and clear the text
        [self.locationLabel removeFromSuperview];
        
    }
    else
    {
        SHHuddleStartStudyingViewController *studyVC = [[SHHuddleStartStudyingViewController alloc]initWithHuddle:self.indvHuddle];
        studyVC.delegate = self;
        
        [self presentPopupViewController:studyVC animationType:MJPopupViewAnimationSlideBottomBottom];
        
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DZNSegmentedControl* control = self.segmentController.control;

    float heightOfTable = [self.segmentController getOccupatingHeight];
    
    float distanceFromBottomToPortrait = self.topPartSize - (profileImageVerticalOffsetFromTop + self.profileImage.frame.size.height);
    float viewableHeight = self.tabBarController.tabBar.frame.origin.y - self.navigationController.navigationBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height;
    
    float normalHeight = viewableHeight + self.topPartSize;
    float extraDistance = (heightOfTable + control.frame.size.height)-viewableHeight;
    NSLog(@"extraDistance: %f",extraDistance);
    if(extraDistance > 0)
    {
        CGSize contentSize = scrollView.contentSize;
        contentSize.height =extraDistance + normalHeight;
        [self.scrollView setContentSize:contentSize];
    }
    else
    {
        CGSize contentSize = scrollView.contentSize;
        contentSize.height = normalHeight;
        [self.scrollView setContentSize:contentSize];
    }

    if(scrollView.contentOffset.y>distanceFromBottomToPortrait)
    {
        [self.view bringSubviewToFront:self.scrollView];
        
    }
    else
    {
        [self.view bringSubviewToFront:self.profileImage];
        [self.view bringSubviewToFront:self.startStudyingButton];
    }
    
    float distanceFromSegmentToTop = distanceFromBottomToPortrait + self.profileImage.frame.size.height + profileImageVerticalOffsetFromTop;
    
    if(self.scrollView.contentOffset.y > distanceFromSegmentToTop )
    {
        float distanceMoved = scrollView.contentOffset.y - distanceFromSegmentToTop;
        CGRect rect = control.frame;
        rect.origin.y=distanceMoved;
        [control setFrame:rect];
        NSLog(@"its at the top");
        //check to see if we should all the table to keep scrolling
        
    }
    else
    {
        CGRect rect = control.frame;
        rect.origin.y=0;
        [control setFrame:rect];
    }
    
}


#pragma mark - Actions

- (void)addItem
{
    [popoverController presentPopoverFromBarButtonItem:self.addButton permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
}

#pragma mark - Huddle Add Delegate Methods

- (void)addMemberTapped
{
    if([[[SHCache sharedCache] membersForHuddle:self.indvHuddle] count] > 9)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Max Amount of Members"
                                                       message: @"Huddles can only have 10 members."
                                                      delegate: nil cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    SHStudentSearchViewController *searchVC = [[SHStudentSearchViewController alloc]init];
    searchVC.type = @"NewMember";
    searchVC.delegate = self.segmentController;
    searchVC.huddle = self.indvHuddle;
    
    [popoverController dismissPopoverAnimated:YES completion:^{
        
        [self presentViewController:searchVC animated:YES completion:nil];
    }];
}

- (void)addResourceTapped
{
    SHNewResourceViewController *newResource = [[SHNewResourceViewController alloc]initWithHuddle:self.indvHuddle];
    newResource.delegate = self;
    
    [popoverController dismissPopoverAnimated:YES completion:^{
        [self presentPopupViewController:newResource animationType:MJPopupViewAnimationSlideBottomBottom dismissed:^{
            //
        }];
    }];
    
}

- (void)addThreadTapped
{
    SHNewQuestionViewController *createThreadVC = [[SHNewQuestionViewController alloc]initWithHuddle:self.indvHuddle];
    createThreadVC.delegate = self;
    
    [popoverController dismissPopoverAnimated:YES completion:^{
        [self presentPopupViewController:createThreadVC animationType:MJPopupViewAnimationSlideBottomBottom dismissed:^{
            //
        }];
    }];
    
    
}

#pragma mark - SHStudentSearchDelgate

- (void)didAddMember:(PFObject *)member
{
    // let the VC know you have requested a student?
    
//    for(PFUser *student in self.huddleMembers){
//        if([[student objectId] isEqual:[member objectId]]){
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
//                                                            message: [NSString stringWithFormat:@"Huddle already has %@", member[SHStudentNameKey]]
//                                                           delegate: nil cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//            return;
//        }
//    }
    
    
}

#pragma mark - Popup delegate methods

- (void)continueTapped
{
    
    //the user will start studying
    self.lastStart = [NSDate date];
    self.indvHuddle[SHHuddleLastStartKey] = self.lastStart;
    self.indvHuddle[SHHuddleOnlineKey] = [NSNumber numberWithBool:true];
    self.isStudying = YES;
    
    [self.indvHuddle save];
    
    //move the bar down
    self.topPartSize = topSize + onlineOffset;
    [self doLayout];
    [self.startStudyingButton setImage:[UIImage imageNamed:@"StopStudying.png"] forState:UIControlStateNormal];
    [self.startStudyingLabel setTextColor:[UIColor redColor]];
    self.startStudyingLabel.text = @"STOP STUDYING";

    [self.view addSubview:self.locationLabel];
    [self.view bringSubviewToFront:self.scrollView];
    [self.view bringSubviewToFront:self.profileImage];
    [self.view bringSubviewToFront:self.startStudyingButton];
    self.locationLabel.text = [NSString stringWithFormat:@"Studying at: %@",[self.indvHuddle[SHHuddleLocationKey] uppercaseString]];
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
}

- (void)cancelTapped
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    
}

#pragma mark - Popoover Delegate Methods

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    //popoverController.delegate = nil;
    //popoverController = nil;
}


@end
