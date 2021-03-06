//
//  SHEditStudyViewController.m
//  Study Huddle
//
//  Created by Jason Dimitriou on 7/9/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import "SHEditStudyViewController.h"
#import "UIColor+HuddleColors.h"
#import "SHCache.h"
#import "SHUtility.h"

@interface SHEditStudyViewController () <UITextViewDelegate>

@property (strong, nonatomic) PFObject *study;

//Headers
@property (strong, nonatomic) UILabel *subjectHeaderLabel;
@property (strong, nonatomic) UILabel *descriptionHeaderLabel;


@end

@implementation SHEditStudyViewController

#define subjectHeaderY firstHeader
#define descriptionHeaderY huddleButtonHeight*2+vertElemSpacing+subjectHeaderY+headerHeight

- (id)initWithStudy:(PFObject *)aStudy
{
    self = [super init];
    if (self) {
        _study = aStudy;
        
        self.modalFrameHeight = 100.0;
        [self.view setFrame:CGRectMake(0.0, 0.0, modalWidth, self.modalFrameHeight)];
        
        [self initHeaders];
        [self initContent];
        [self setFrames];

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initHeaders
{
    //Resource Header
    self.headerLabel.text = @"Study Session";
    [self.continueButton setTitle:@"Save" forState:UIControlStateNormal];
    
    //Subjet Header
    self.subjectHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(horiViewSpacing+horiElemSpacing, subjectHeaderY, headerWidth, headerHeight)];
    [self.subjectHeaderLabel setFont:self.headerFont];
    [self.subjectHeaderLabel setTextColor:[UIColor huddleSilver]];
    [self.subjectHeaderLabel setLineBreakMode:NSLineBreakByWordWrapping];
    self.subjectHeaderLabel.textAlignment = NSTextAlignmentLeft;
    self.subjectHeaderLabel.text = @"Subject";
    [self.view addSubview:self.subjectHeaderLabel];
    
    //Description Header
    self.descriptionHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(horiViewSpacing +horiElemSpacing, descriptionHeaderY, headerWidth, headerHeight)];
    [self.descriptionHeaderLabel setFont:self.headerFont];
    [self.descriptionHeaderLabel setTextColor:[UIColor huddleSilver]];
    [self.descriptionHeaderLabel setLineBreakMode:NSLineBreakByWordWrapping];
    self.descriptionHeaderLabel.textAlignment = NSTextAlignmentLeft;
    self.descriptionHeaderLabel.text = @"Description";
    [self.view addSubview:self.descriptionHeaderLabel];
    
    
}

- (void)initContent
{
   
    CGRect initialButton = CGRectMake(vertViewSpacing, subjectHeaderY+headerHeight, huddleButtonWidth, huddleButtonHeight);
    NSArray *classNames = [SHUtility namesForObjects:[[SHCache sharedCache]classes] withKey:SHClassShortNameKey];
    NSMutableDictionary *classObjects = [[NSMutableDictionary alloc]initWithObjects:[[SHCache sharedCache]classes] forKeys:classNames];
    self.subjectButtons = [[SHHuddleButtons alloc]initWithFrame:initialButton items:classObjects addButton:nil];
    self.subjectButtons.delegate = self;
    [self.subjectButtons setViewController:self];
    self.subjectButtons.multipleSelection = YES;
    [self.subjectButtons setInitialPressedButtons:[SHUtility namesForObjects:self.study[SHStudyClassesKey] withKey:SHClassShortNameKey]];
    
    //Description Text View
    self.descriptionTextView = [[UITextView alloc]init];
    self.descriptionTextView.layer.cornerRadius = 2;
    self.descriptionTextView.delegate = self;
    [self.view addSubview:self.descriptionTextView];
    
    
}

- (void)setFrames
{
    [self.descriptionHeaderLabel setFrame:CGRectMake(horiViewSpacing, self.modalFrameHeight-10, headerWidth, headerHeight)];
    [self.descriptionTextView setFrame:CGRectMake(horiViewSpacing, self.modalFrameHeight-10+headerHeight, modalContentWidth, 100.0)];
    
    self.modalFrameHeight += headerHeight+100.0;
    
    [self.view setFrame:CGRectMake(0.0, 0.0, modalWidth, self.modalFrameHeight)];
    
}

- (void)continueAction
{
    self.study[SHStudyDescriptionKey] = self.descriptionTextView.text;
    
    [self.study[SHStudyClassesKey] removeAllObjects];
    self.study[SHStudyClassesKey] = self.subjectButtons.multipleSelectedButtonsObjects;
    
    [self.study saveInBackground];
    
    [self.delegate continueTapped];
    
    [self cancelAction];
    
    
}

#pragma mark - Text View Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self moveUp:YES height:60.0];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self moveUp:NO height:60.0];
}


@end
