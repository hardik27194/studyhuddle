//
//  SHTextBar.h
//  Study Huddle
//
//  Created by Jose Rafael Leon Bigio Anton on 7/8/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface SHTextBar : UIView
@property (nonatomic,strong) HPGrowingTextView* textField;
@property (nonatomic,strong) UIButton* postButton;
@property (nonatomic,strong) UIButton* imageButton;

@end
