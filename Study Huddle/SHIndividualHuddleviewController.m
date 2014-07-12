//
//  SHProfileViewController.m
//  Study Huddle
//
//  Created by Jason Dimitriou on 6/14/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import "SHIndividualHuddleviewController.h"
#import "UIColor+HuddleColors.h"
#import "SHConstants.h"
#import "SHHuddleSegmentViewController.h"
#import "SHNewQuestionViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "SHHuddleAddViewController.h"
#import "FPPopoverController.h"
#import "WYPopoverController.h"
#import "SHNewResourceViewController.h"
#import "SHStudentSearchViewController.h"



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


#define topPartSize 170




#define nameLabelFont [UIFont boldSystemFontOfSize:15]

#define sideItemsFont [UIFont systemFontOfSize:7]


@interface SHIndividualHuddleviewController () <UIScrollViewDelegate, SHModalViewControllerDelegate, WYPopoverControllerDelegate, SHHuddleAddDelegate>
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

@property (nonatomic,strong) UIButton* startStudyingButton;
@property BOOL isStudying;
@property int initialSection;

@property (nonatomic,strong) NSDate* lastStart;

@property (strong, nonatomic) UIBarButtonItem *addButton;


@end

@implementation SHIndividualHuddleviewController


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
        self.indvHuddle = aHuddle;
        
        self.title = @"Huddle";
        self.tabBarItem.image = [UIImage imageNamed:@"profile.png"];
        
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
    
    
    
    
    //important coordinates
    float centerX = self.view.bounds.origin.x + self.view.bounds.size.width/2;
    
    float bottomOfNavBar = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    //float middleHeight = (self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)/2;
    
    //background
    UIImageView* backGroundImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shBackground.png"]];
    [backGroundImg setFrame:self.view.frame];
    [self.view addSubview:backGroundImg];
    
    
    
    //set up portrait view
    CGRect profileFrame = CGRectMake(centerX-profileImageWidth/2, bottomOfNavBar + profileImageVerticalOffsetFromTop, profileImageWidth, profileImageHeight);
    
    //set up name label
    self.fullNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(centerX - fullNameWidth/2,profileFrame.origin.y + profileFrame.size.height + fullNameLabelVerticalOffsetFromPicture, fullNameWidth, fullNameHeight)];
    self.fullNameLabel.text = [self.indvHuddle[@"huddleName"] uppercaseString];
    [self.fullNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.fullNameLabel setFont: nameLabelFont];
    [self.fullNameLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:self.fullNameLabel];
    
    
    //set up the side items
    float leftPictureEdge = profileFrame.origin.x;
    float rightPictureEdge = leftPictureEdge + profileFrame.size.width;
    float leftMidPoint = leftPictureEdge/2-sideItemDiameters/2;
    float rightMidPoint = rightPictureEdge + leftMidPoint;
    float midYPoint = profileFrame.origin.y + profileFrame.size.height/2 - sideItemDiameters/2;
    self.startStudyingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startStudyingButton addTarget:self action:@selector(setStudy) forControlEvents:UIControlEventTouchUpInside];
    [self.startStudyingButton setFrame:CGRectMake(leftMidPoint, midYPoint, sideItemDiameters, sideItemDiameters)];
    [self.startStudyingButton setImage:[UIImage imageNamed:@"startStudying.png"] forState:UIControlStateNormal];
    //[self.startStudyingButton setBackgroundColor:[UIColor yellowColor]];
    self.startStudyingLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.startStudyingButton.frame.origin.x + self.startStudyingButton.frame.size.width/2 - sideLabelsWidth/2, self.startStudyingButton.frame.origin.y + self.startStudyingButton.frame.size.height + sideItemLabelsVerticalOffsetFromCircle, sideLabelsWidth, sideLabelHeight)];
    self.startStudyingLabel.text = @"START STUDYING";
    [self.startStudyingLabel setTextAlignment:NSTextAlignmentCenter];
    [self.startStudyingLabel setFont:sideItemsFont];
    // [self.startStudyingLabel setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.startStudyingLabel];
    
    
    UIImageView* hoursStudiedCircle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hoursStudying.png"]];
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
    CGRect scrollViewFrame = CGRectMake(self.view.bounds.origin.x, bottomOfNavBar, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.frame.size.height);
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    //self.scrollView.backgroundColor = [UIColor redColor];
    self.scrollView.delegate = self;
    CGSize sViewContentSize = scrollViewFrame.size;
    float heightOfTop = (self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)/2;
    sViewContentSize.height+=heightOfTop + 9999;
    [self.scrollView setContentSize:sViewContentSize];
    [self.view addSubview:self.scrollView];
    
    
    
    //set up segmented view
    self.segmentContainer = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.scrollView.bounds.origin.y + topPartSize, self.view.frame.size.width, self.view.frame.size.height*10)];
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
    
    //add it in the right order
    //[self.view addSubview:extendedBG];
    
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.profileImage];
    [self.view addSubview:self.startStudyingButton];
    
    //get the last study date
    self.lastStart = self.indvHuddle[@"lastStart"];
    
    
    
    
    //set timer
    [NSTimer scheduledTimerWithTimeInterval:60
                                     target:self
                                   selector:@selector(updateHoursStudied)
                                   userInfo:nil
                                    repeats:YES];
    
    SHHuddleAddViewController *addVC = [[SHHuddleAddViewController alloc]init];
    [addVC.view setFrame:CGRectMake(305, 55.0, 100.0, 200.0)];
    addVC.preferredContentSize = CGSizeMake(120, 110);
    addVC.delegate = self;
    popoverController = [[WYPopoverController alloc]initWithContentViewController:addVC];
    popoverController.delegate = self;
    [WYPopoverController setDefaultTheme:[WYPopoverTheme theme]];
    
    WYPopoverBackgroundView *appearance = [WYPopoverBackgroundView appearance];
    [appearance setTintColor:[UIColor huddleSilver]];
    
    
}


-(void)updateHoursStudied
{
    
    NSDate* date = [NSDate date];
    NSTimeInterval diff = [date timeIntervalSinceDate:self.lastStart];
    if(self.isStudying)
    {
        self.lastStart = date;
        NSString* hoursPrevStudied = self.indvHuddle[@"hoursStudied"];
        double previousTimeStudied = [hoursPrevStudied doubleValue];
        double secondsStudied = diff + previousTimeStudied;
        int hoursStudied = secondsStudied/3600;
        self.hoursStudiedLabel.text = [NSString stringWithFormat:@"%d",hoursStudied];
        
        self.indvHuddle[@"hoursStudied"] = [NSString stringWithFormat:@"%f",(diff+previousTimeStudied)];
        [self.indvHuddle saveInBackground];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isStudying = [self.indvHuddle[@"isStudying"] boolValue];
    //update the studying button
    if(self.isStudying)
    {
        [self.startStudyingButton setImage:[UIImage imageNamed:@"stopStudying.png"] forState:UIControlStateNormal];
        [self.startStudyingLabel setTextColor:[UIColor redColor]];
         self.startStudyingLabel.text = @"STOP STUDYING";
    }
    else
    {
        [self.startStudyingButton setImage:[UIImage imageNamed:@"startStudying.png"] forState:UIControlStateNormal];
        [self.startStudyingLabel setTextColor:[UIColor greenColor]];
         self.startStudyingLabel.text = @"START STUDYING";
    }
}

-(void)setStudy
{
    if(self.isStudying)
    {
        //the user will stop their studying session
        self.indvHuddle[@"isStudying"] = [NSNumber numberWithBool:NO];
        self.isStudying =   NO;
        [self.startStudyingButton setImage:[UIImage imageNamed:@"startStudying.png"] forState:UIControlStateNormal];
        [self.startStudyingLabel setTextColor:[UIColor greenColor]];
         self.startStudyingLabel.text = @"START STUDYING";
    }
    else
    {
        //the user will start studying
        self.lastStart = [NSDate date];
        self.indvHuddle[@"lastStudyDate"] = self.lastStart;
        self.indvHuddle[@"isStudying"] =[NSNumber numberWithBool:YES];
        self.isStudying = YES;
        [self.startStudyingButton setImage:[UIImage imageNamed:@"stopStudying.png"] forState:UIControlStateNormal];
        [self.startStudyingLabel setTextColor:[UIColor redColor]];
         self.startStudyingLabel.text = @"STOP STUDYING";
    }
    
    [self.indvHuddle saveInBackground];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    DZNSegmentedControl* control = self.segmentController.control;
    
    
    float distanceFromBottomToPortrait = topPartSize - (profileImageVerticalOffsetFromTop + self.profileImage.frame.size.height);
    
    
    
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



#pragma mark - Popoover Delegate Methods

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    popoverController.delegate = nil;
    popoverController = nil;
}

#pragma mark - Popup delegate methods


- (void)cancelTapped
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
}




/*
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
 {
 float distanceFromBottomToPicture = self.profileHeaderContainer.frame.origin.y + self.profileHeaderContainer.frame.size.height-self.profileImage.frame.origin.y - self.profileImage.frame.size.height;
 
 NSLog(@"contentoffset: %f",scrollView.contentOffset.y);
 
 if(scrollView.contentOffset.y>distanceFromBottomToPicture)
 {
 NSLog(@"its touching it!");
 [self.view bringSubviewToFront:self.scrollView];
 }
 else{
 [self.view bringSubviewToFront:self.profileImage];
 }
 
 
 if(scrollView.contentOffset.y>0 && !self.tableIsUp)
 {
 [scrollView setScrollEnabled:NO];
 [UIView animateWithDuration:5 animations:^{
 
 scrollView.contentOffset = CGPointMake(0, self.profileHeaderContainer.frame.size.height);
 }
 completion:^ (BOOL finished)
 {
 if (finished) {
 NSLog(@"finished");
 [scrollView setScrollEnabled:YES];
 self.tableIsUp = YES;
 }
 }];
 
 }
 else
 {
 [scrollView setScrollEnabled:NO];
 [UIView animateWithDuration:5 animations:^{
 
 scrollView.contentOffset = CGPointMake(0, 0);
 }
 completion:^ (BOOL finished)
 {
 if (finished) {
 NSLog(@"finished");
 [scrollView setScrollEnabled:YES];
 self.tableIsUp = NO;
 }
 }];
 }
 
 if(scrollView.contentOffset.y>self.profileHeaderContainer.frame.size.height)
 {
 NSLog(@"it got here");
 }
 
 
 }
 */

/*
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
 {
 NSLog(@"content offset: %f",self.scrollView.contentOffset.y);
 float distanceFromBottomToPicture = self.profileHeaderContainer.frame.origin.y + self.profileHeaderContainer.frame.size.height-self.profileImage.frame.origin.y - self.profileImage.frame.size.height;
 
 if(scrollView.contentOffset.y>distanceFromBottomToPicture)
 {
 // NSLog(@"its touching it!");
 [self.view bringSubviewToFront:self.scrollView];
 }
 else{
 [self.view bringSubviewToFront:self.profileImage];
 }
 
 if(scrollView.contentOffset.y>0 && !self.inMiddleOfAnimation && !self.isGoingDown && !self.isUp)
 {
 self.inMiddleOfAnimation = YES;
 self.isGoingUp = YES;
 [self.scrollView setScrollEnabled:NO];
 [self.scrollView setContentOffset:CGPointMake(0, self.profileHeaderContainer.frame.size.height) withTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear] duration:0.5];
 }
 
 NSLog(@"top: %f",self.profileHeaderContainer.frame.size.height);
 NSLog(@"current: %f",self.scrollView.contentOffset.y);
 
 if(scrollView.contentOffset.y <= self.profileHeaderContainer.frame.size.height-20 && !self.inMiddleOfAnimation && !self.isGoingUp)
 {
 NSLog(@"going down");
 self.inMiddleOfAnimation = YES;
 self.isGoingDown = YES;
 [self.scrollView setScrollEnabled:NO];
 [self.scrollView setContentOffset:CGPointMake(0, 0) withTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear] duration:0.5];
 }
 
 
 
 
 
 
 
 }
 
 
 - (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
 {
 NSLog(@"animation ended");
 [self.scrollView setScrollEnabled:YES];
 self.inMiddleOfAnimation = NO;
 
 self.isGoingUp = NO;
 self.isGoingDown = NO;
 
 if(self.scrollView.contentOffset.y > 0) self.isUp = YES;
 else self.isUp = NO;
 }
 
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
