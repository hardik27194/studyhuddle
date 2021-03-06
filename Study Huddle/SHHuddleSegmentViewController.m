//
//  SHHuddleSegmentViewController.m
//  Study Huddle
//
//  Created by Jason Dimitriou on 6/24/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import "SHHuddleSegmentViewController.h"
#import "UIColor+HuddleColors.h"
#import "SHClassCell.h"
#import "SHRequestCell.h"
#import "SHConstants.h"
#import "SHStudentCell.h"
#import "SHStudyCell.h"
#import "SHChatCell.h"
#import "SHResourceCell.h"
#import "SHVisitorProfileViewController.h"
#import "SHProfileViewController.h"
#import "SHIndividualHuddleViewController.h"
#import "SHUtility.h"
#import "SHStudentSearchViewController.h"
#import "SHCategoryCell.h"
#import "SHNewResourceViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "SHChatEntryViewController.h"
#import "SHResourceListViewController.h"
#import "SHHuddleJoinRequestViewController.h"
#import "SHCache.h"
#import "RoomView.h"


@interface SHHuddleSegmentViewController () <SHBaseCellDelegate, UINavigationControllerDelegate, SHStudentSearchDelegate>

@property (strong, nonatomic) PFObject *segHuddle;

@property (strong, nonatomic) NSString *CellIdentifier;

@property (nonatomic, strong) NSMutableDictionary *segCellIdentifiers;

@property (strong, nonatomic) NSArray *segMenu;

@property (strong, nonatomic) NSMutableDictionary *segmentData;
@property (strong, nonatomic) NSMutableArray *membersDataArray;
@property (strong, nonatomic) NSMutableArray *pendingMembersDataArray;

@property (strong, nonatomic) NSMutableArray *chatCategoriesDataArray;

@property (strong, nonatomic) NSMutableArray *threadDataArray;
@property (strong, nonatomic) NSMutableArray *resourceCategoriesDataArray;

@property (strong, nonatomic) NSMutableArray *encapsulatingDataArray;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property int initialSection;

@property (strong, nonatomic) SHStudentSearchViewController *searchVC;
@property (strong, nonatomic) SHNewResourceViewController *addResourceVC;

@end


@implementation SHHuddleSegmentViewController

@synthesize CellIdentifier;
@synthesize refreshControl;

-(id)initWithHuddle:(PFObject *)aHuddle
{
    self = [super init];
    if(self)
    {
        _segHuddle = aHuddle;
        self.initialSection = 1;
        CellIdentifier = [[NSString alloc]init];
        
        self.segCellIdentifiers = [[NSMutableDictionary alloc]init];
        
        self.segmentData = [[NSMutableDictionary alloc]init];
        
        self.segMenu = [[NSArray alloc]initWithObjects:@"MEMBERS", @"RESOURCES", @"CHAT", nil];
        

        
    }
    return self;
}

-(id)initWithHuddle:(PFObject *)aHuddle andInitialSection:(int)section
{
    self = [self initWithHuddle:aHuddle];
    self.initialSection = section;
    return self;
}

+ (void)load
{
    [[DZNSegmentedControl appearance] setBackgroundColor:[UIColor clearColor]];
    [[DZNSegmentedControl appearance] setTintColor:[UIColor huddleOrange]];
    [[DZNSegmentedControl appearance] setHairlineColor:[UIColor huddleSilver]];
    
    [[DZNSegmentedControl appearance] setFont:segmentFont];
    [[DZNSegmentedControl appearance] setSelectionIndicatorHeight:2.5];
    [[DZNSegmentedControl appearance] setAnimationDuration:0.125];
    
}

- (void)loadView
{
    [super loadView];
    
    self.tableView.dataSource = self;
    
    self.membersDataArray = [[NSMutableArray alloc]init];
    self.pendingMembersDataArray = [[NSMutableArray alloc]init];
    self.chatCategoriesDataArray = [[NSMutableArray alloc]init];
    self.resourceCategoriesDataArray = [[NSMutableArray alloc]init];
    self.encapsulatingDataArray = [[NSMutableArray alloc]initWithObjects:self.membersDataArray, self.resourceCategoriesDataArray, self.chatCategoriesDataArray, nil];
    

    [self loadHuddleDataRefresh:false];
        
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    //Tableview
    CGRect tableViewFrame = CGRectMake(tableViewX, tableViewY, tableViewDimX, tableViewDimY);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    
    //Set segment menu titles
    [self.segCellIdentifiers setObject:SHStudentCellIdentifier forKey:[@"Members" uppercaseString]];
    [self.segCellIdentifiers setObject:SHChatCellIdentifier forKey:[@"Chat" uppercaseString]];
    [self.segCellIdentifiers setObject:SHCategoryCellIdentifier forKey:[@"Resources" uppercaseString]];
    
    //Segment
    [self.view addSubview:self.control];
    
    [self.tableView registerClass:[SHStudentCell class] forCellReuseIdentifier:SHStudentCellIdentifier];
    [self.tableView registerClass:[SHCategoryCell class] forCellReuseIdentifier:SHCategoryCellIdentifier];
    [self.tableView registerClass:[SHChatCell class] forCellReuseIdentifier:SHChatCellIdentifier];
    self.control.backgroundColor = [UIColor whiteColor];
    
}

- (void)refreshTable {
    //TODO: refresh your data
    [refreshControl endRefreshing];
    [self loadHuddleDataRefresh:true];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)setHuddle:(PFObject *)aHuddle
{
    _segHuddle = aHuddle;
    [self loadHuddleDataRefresh:true];
}

-(BOOL)loadHuddleDataRefresh:(BOOL)refresh
{
    BOOL loadError = true;
    
    //[self.segHuddle fetch];
    
    [self.resourceCategoriesDataArray removeAllObjects];
    [self.resourceCategoriesDataArray addObjectsFromArray:[[SHCache sharedCache] resourceCategoriesForHuddle:self.segHuddle]];
    
    [self.membersDataArray removeAllObjects];
    [self.membersDataArray addObjectsFromArray:[[SHCache sharedCache] membersForHuddle:self.segHuddle]];
    
    [self.pendingMembersDataArray removeAllObjects];
    [self.pendingMembersDataArray addObjectsFromArray:[[SHCache sharedCache] pendingMembersForHuddle:self.segHuddle]];
    
    [self.chatCategoriesDataArray removeAllObjects];
    [self.chatCategoriesDataArray addObjectsFromArray:[[SHCache sharedCache] chatCategoriessForHuddle:self.segHuddle]];
    
    [self.tableView reloadData];

    switch (self.initialSection) {
        case 0:
            self.currentRowsToDisplay = self.membersDataArray.count;
            break;
        case 1:
            self.currentRowsToDisplay = self.resourceCategoriesDataArray.count;
            break;
        case 2:
            self.currentRowsToDisplay = self.chatCategoriesDataArray.count;
            break;
        default:
            break;
    }

    
    return loadError;
}

-(BOOL)updateDataAndStartIn:(int)section
{
    BOOL loadError = true;
    
    //[self.segHuddle fetch];
    
    [self.resourceCategoriesDataArray removeAllObjects];
    [self.resourceCategoriesDataArray addObjectsFromArray:[[SHCache sharedCache] resourceCategoriesForHuddle:self.segHuddle]];
    
    [self.membersDataArray removeAllObjects];
    [self.membersDataArray addObjectsFromArray:[[SHCache sharedCache] membersForHuddle:self.segHuddle]];
    
    [self.chatCategoriesDataArray removeAllObjects];
    [self.chatCategoriesDataArray addObjectsFromArray:[[SHCache sharedCache] chatCategoriessForHuddle:self.segHuddle]];
    
   
    
    switch (section) {
        case 0:
            self.currentRowsToDisplay = self.membersDataArray.count;
            break;
        case 1:
            self.currentRowsToDisplay = self.resourceCategoriesDataArray.count;
            break;
        case 2:
            self.currentRowsToDisplay = self.chatCategoriesDataArray.count;
            break;
        default:
            break;
    }
    
     [self.tableView reloadData];
    
    return loadError;
}

#pragma mark - DZNSegmentController

- (DZNSegmentedControl *)control
{
    
    if (!_control)
    {
        _control = [[DZNSegmentedControl alloc] initWithItems:self.segMenu];
        _control.delegate = self;
        _control.selectedSegmentIndex = self.initialSection;
        _control.inverseTitles = NO;
        _control.tintColor = [UIColor huddleOrange];
        _control.hairlineColor = [UIColor grayColor];
        //        _control.hairlineColor = self.view.tintColor;
        _control.showsCount = NO;
        //        _control.autoAdjustSelectionIndicatorWidth = YES;
        
        
        [_control addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    }
    return _control;
}

- (void)selectedSegment:(DZNSegmentedControl *)control
{
    self.currentRowsToDisplay = [[self.encapsulatingDataArray objectAtIndex:control.selectedSegmentIndex]count];
    [self.tableView reloadData];
}


- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view
{
    return UIBarPositionBottom;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
        return 25.0;
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.control titleForSegmentAtIndex:self.control.selectedSegmentIndex] isEqual:@"MEMBERS"])
        return SHHuddleCellHeight;
    else if([[self.control titleForSegmentAtIndex:self.control.selectedSegmentIndex] isEqual:@"RESOURCES"])
        return SHCategoryCellHeight;
    else if([[self.control titleForSegmentAtIndex:self.control.selectedSegmentIndex] isEqual:@"CHAT"])
        return SHChatCellHeight;
    else
        return SHHuddleCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.control titleForSegmentAtIndex:self.control.selectedSegmentIndex] isEqual:@"MEMBERS"])
    {
        PFUser *student = self.membersDataArray[indexPath.row];
        
        if([student isEqual:[PFUser currentUser]])
        {
            SHProfileViewController *profileVC = [[SHProfileViewController alloc]initWithStudent:student];
            
            [self.navigationController pushViewController:profileVC animated:YES];
        }
        else{
            SHVisitorProfileViewController *visitorVC = [[SHVisitorProfileViewController alloc]initWithStudent:student];
            
            [self.navigationController pushViewController:visitorVC animated:YES];
        }
    }
    else if([[self.control titleForSegmentAtIndex:self.control.selectedSegmentIndex] isEqual:@"RESOURCES"])
    {
        PFObject *category = self.resourceCategoriesDataArray[indexPath.row];
        
        SHResourceListViewController *resourceListVC = [[SHResourceListViewController alloc] initWithResourceCategory:category];
        
        [self.navigationController pushViewController:resourceListVC animated:YES];
    }
    else
    {
        //        PFObject* chatEntryObj = [(SHChatCell*)cell getChatEntryObj];
        //        //NSLog(@"chatEntryObj: , %@",chatEntryObj);
        //        //SHChatEntryViewController* chatEntryVC = [[SHChatEntryViewController alloc]initWithChatEntry:chatEntryObj];
        //        //[self.navigationController pushViewController:chatEntryVC animated:YES];*/
        //        [chatEntryObj fetchIfNeeded];
        //        RoomView *roomView = [[RoomView alloc] initWithChatCategoryOwner:[chatEntryObj objectId]];
        //        roomView.hidesBottomBarWhenPushed = YES;
        //        [self.navigationController pushViewController:roomView animated:YES];
        
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.control.selectedSegmentIndex == 0 && [self.pendingMembersDataArray count] > 0){
        return 2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 1)
        return [self.pendingMembersDataArray count];
    
    return self.currentRowsToDisplay;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 1)
        return @"Pending Requests to Join";

    return @"";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if([[self.segHuddle[SHHuddleCreatorKey] objectId] isEqual:[[PFUser currentUser] objectId]])
    {
        if(self.control.selectedSegmentIndex == 0)
            return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // &&##
        PFObject *notification = [PFObject objectWithClassName:SHNotificationParseClass];
        notification[SHNotificationTitleKey] = self.segHuddle[SHHuddleNameKey];
        notification[SHNotificationTypeKey] = SHNotificationRemovedFromHuddleType;
        notification[SHNotificationDescriptionKey] = @"You've been removed from the huddle";
        notification[SHNotificationHuddleKey] = self.segHuddle;
        notification[SHNotificationToStudentKey] = self.membersDataArray[indexPath.row];
        
        [notification saveInBackground];
        
        [[SHCache sharedCache] removeHuddleMember:self.membersDataArray[indexPath.row] fromHuddle:self.segHuddle];
        [self.membersDataArray removeObjectAtIndex:indexPath.row];
        self.currentRowsToDisplay--;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tableView reloadData];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellIdentifier = [self.segCellIdentifiers objectForKey:[self.control titleForSegmentAtIndex:self.control.selectedSegmentIndex]];

    if([CellIdentifier isEqual:SHStudentCellIdentifier])
    {
        PFUser *studentObject;
        
        if(indexPath.section)
            studentObject = [self.pendingMembersDataArray objectAtIndex:(int)indexPath.row];
        else
            studentObject = [self.membersDataArray objectAtIndex:(int)indexPath.row];
        
        SHStudentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.delegate = self;
        
        [cell setStudent:studentObject];
        [cell layoutIfNeeded];
        
        return cell;
    }
    else if([CellIdentifier isEqual:SHCategoryCellIdentifier])
    {
        PFObject *categoryObject = [self.resourceCategoriesDataArray objectAtIndex:(int)indexPath.row];
        SHCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.delegate = self;
        
        [cell setCategory:categoryObject];
        [cell layoutIfNeeded];
        
        return cell;
    }
    else if([CellIdentifier isEqual:SHChatCellIdentifier])
    {
        PFObject *chatEntryObj = [self.chatCategoriesDataArray objectAtIndex:(int)indexPath.row];
        SHChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.delegate = self;
        
        [cell setChatEntry:chatEntryObj];
        [cell layoutIfNeeded];
        
        return cell;
    }
    
    
    return nil;
    
}

- (void)didTapTitleCell:(SHBaseTextCell *)cell
{
    if ([cell isKindOfClass:[SHStudentCell class]] ) {
        SHStudentCell *studentCell = (SHStudentCell *)cell;
        
        if([studentCell.student isEqual:[PFUser currentUser]])
        {
            SHProfileViewController *profileVC = [[SHProfileViewController alloc]initWithStudent:studentCell.student];
            
            [self.navigationController pushViewController:profileVC animated:YES];
        }
        else{
            SHVisitorProfileViewController *visitorVC = [[SHVisitorProfileViewController alloc]initWithStudent:studentCell.student];
            
            [self.navigationController pushViewController:visitorVC animated:YES];
        }


    }
    else if([cell isKindOfClass:[SHChatCell class]])
    {
        PFObject* chatEntryObj = [(SHChatCell*)cell getChatEntryObj];
        //NSLog(@"chatEntryObj: , %@",chatEntryObj);
        //SHChatEntryViewController* chatEntryVC = [[SHChatEntryViewController alloc]initWithChatEntry:chatEntryObj];
        //[self.navigationController pushViewController:chatEntryVC animated:YES];*/
        [chatEntryObj fetchIfNeeded];
        RoomView *roomView = [[RoomView alloc] initWithChatCategoryOwner:[chatEntryObj objectId]];
        roomView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:roomView animated:YES];

    }
    if ([cell isKindOfClass:[SHCategoryCell class]] ) {
        SHCategoryCell *categoryCell = (SHCategoryCell *)cell;
        
        SHResourceListViewController *resourceListVC = [[SHResourceListViewController alloc] initWithResourceCategory:categoryCell.category];
        
        
        [self.navigationController pushViewController:resourceListVC animated:YES];
        

    }
    
}

#pragma mark - Popup delegate methods

- (void)cancelTapped
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
}


#pragma mark - SHStudentSearchDelgate

- (void)didAddMember:(PFUser *)member
{
    [[SHCache sharedCache] setNewPendingMember:member forHuddle:self.segHuddle];
    [self.pendingMembersDataArray addObject:member];
    
    [self.tableView reloadData];
    [self.control setSelectedSegmentIndex:0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y<0)
        [self.parentScrollView setScrollEnabled:YES];
}

-(float)getOccupatingHeight
{
    //check if its in study, classes or online
    float cellHeight = 0;
    float add = 0;
    switch (self.control.selectedSegmentIndex)
    {
        case 0:
            cellHeight = SHStudentCellHeight;
            add = 1;
            break;
        case 1:
            cellHeight = SHCategoryCellHeight;
            add = 1;
            break;
        case 2:
            cellHeight = SHChatCellHeight;
            add = 0;
            break;
        default:
            break;
    }
    
    return cellHeight*(self.currentRowsToDisplay+add);
    
}




@end
