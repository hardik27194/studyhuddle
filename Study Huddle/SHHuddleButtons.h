//
//  SHHuddleButtons.h
//  Study Huddle
//
//  Created by Jason Dimitriou on 7/3/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SHHuddleButtons : UIView

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *selectedTextColor;
@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) UIFont *headerFont;
@property (strong, nonatomic) NSString *addButtonPlaceHolder;

@property (strong, nonatomic) PFObject *selectedButtonObject;
@property (strong, nonatomic) NSMutableArray *multipleSelectedButtonsObjects;


@property BOOL multipleSelection;
@property BOOL addButtonSet;

- (id)initWithFrame:(CGRect)frame items:(NSMutableDictionary *)buttonDictionary addButton:(NSString *) addString;
- (void)setInitialPressedButtons:(NSArray *)buttons;
- (float)getButtonHeight;

@end



@protocol SHHuddleButtonsDelegate <NSObject>
@optional

- (void)didChangeButton:(NSString *)selectedText;
- (void)buttonAdded:(CGFloat)buttonsHeight;


@end
