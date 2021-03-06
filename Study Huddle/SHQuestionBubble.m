
//  SHThreadBubble.m
//  Study Huddle
//
//  Created by Jose Rafael Leon Bigio Anton on 7/5/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import "SHQuestionBubble.h"
#import "SHConstants.h"
#import "UIColor+HuddleColors.h"

#define titleHeight 40
#define titleWidth 250
#define horizontalOffest 20

#define contentWidth 250


#define buttonsHeight 20
#define buttonsWidth 80

#define charWidth 12
#define lineHeight 23

#define roundness 3.0f

#define sideButtonOffsetFromRightEdge 20
#define spaceBetweenTextAndLine 3

@interface SHQuestionBubble()

@property UILabel* titleLabel;
@property UILabel* userLabel;
@property UILabel* contentLabel;
@property UIButton* replyButton;
@property PFObject* questionObject;
@property PFObject* parent;

@end

@implementation SHQuestionBubble


- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame andTitle:@"blank" andContent:@"blank" andParent:nil];
    return self;
}

-(id)initWithFrame:(CGRect)frame andTitle:(NSString*) title andContent: (NSString*)content
{
    self = [self initWithFrame:frame andTitle:title andContent:content andParent:nil];
    return self;
}

-(id)initWithQuestion: (PFObject*)questionObject andFrame: (CGRect)frame
{
    self = [super initWithFrame:frame];
    
    _questionObject = questionObject;
    [_questionObject fetchIfNeeded];
    [self doLayout];
    
    return self;
    
}



-(void)doLayout
{
    self.backgroundColor = [UIColor lightGrayColor];
    
    float width = self.frame.size.width;
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(horizontalOffest, 0, width-horizontalOffest-roundness, titleHeight)];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.text = self.questionObject[SHQuestionCreatorName];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    self.titleLabel.textColor = [UIColor huddleSilver];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    self.titleLabel.layer.cornerRadius = roundness;
    
    
    //the edit button/replyButton
    NSString* currentUserID = [[PFUser currentUser] objectId];
    NSString* creatorID = self.questionObject[SHQuestionCreatorID];
    CGRect editFrame = CGRectMake(width-sideButtonOffsetFromRightEdge - buttonsWidth, self.titleLabel.frame.origin.y + (titleHeight - buttonsHeight)/2, buttonsWidth, buttonsHeight);
    UIButton* editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    editButton.frame = editFrame;
    editButton.backgroundColor = [UIColor whiteColor];
    [editButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [editButton setTitleColor:[UIColor huddleBlue] forState:UIControlStateNormal];
    [editButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    
    BOOL shouldSeeEditButton = ([currentUserID isEqual:creatorID]);
    if(shouldSeeEditButton)
    {
        [editButton setTitle:@"EDIT POST" forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [editButton setTitle:@"REPLY TO POST" forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(replyTapped) forControlEvents:UIControlEventTouchUpInside];
    }


    
    self.contentLabel = [[UILabel alloc]init];
    //self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(horizontalOffest, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height, width-horizontalOffest-roundness, contentCalcHeight)];
    self.contentLabel.backgroundColor = [UIColor whiteColor];
    self.contentLabel.text = self.questionObject[SHQuestionQuestion];
    CGSize descriptionSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(width-horizontalOffest-roundness, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = [UIColor huddleSilver];
    [self.contentLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentLabel setNumberOfLines:0];
    self.contentLabel.layer.cornerRadius = roundness;
    self.contentLabel.frame = CGRectMake(horizontalOffest, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height-2, width-horizontalOffest-roundness, descriptionSize.height);

    
    
    //adjust the views size
    CGRect frame = self.frame;
    frame.size.height = titleHeight + descriptionSize.height + buttonsHeight + spaceBetweenTextAndLine;
    self.frame = frame;
    [self addSubview:self.contentLabel];
    [self addSubview:self.titleLabel];
    [self addSubview:editButton];

    
    //make a frame around it
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = roundness;
    
}

-(void)replyTapped
{
    [self.delegate didTapReply:self.questionObject];
}

-(void)editTapped
{
    [self.delegate didTapEdit:self.questionObject];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
