//
//  SHBaseTextCell.h
//  Study Huddle
//
//  Created by Jason Dimitriou on 6/20/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHBaseTextCell : UITableViewCell

@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *arrowButton;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *descriptionFont;
@property (nonatomic, strong) NSDictionary *titleDict;
@property (nonatomic, strong) NSDictionary *descriptionDict;

- (void)didTapTitleButtonAction:(id)sender;

@end


@protocol SHBaseCellDelegate <NSObject>
@optional

- (void)didTapTitleCell:(SHBaseTextCell *)cell;

@end


#define descriptionLabelY vertViewSpacing+23.0
#define nameMaxWidth 200.0f
#define descriptionMaxWidth 250.0f

//Arrow
#define arrowX 285.0f
#define arrowY 11.5
#define arrowDimX 10.0f
#define arrowDimY 17.0f
