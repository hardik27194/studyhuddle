//
//  SHSearchViewController.m
//  Study Huddle
//
//  Created by Jason Dimitriou on 7/15/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import "SHSearchViewController.h"
#import "SHStudentCell.h"
#import "SHClassCell.h"
#import "SHHuddleCell.h"
#import "SHConstants.h"
#import <Parse/Parse.h>
#import "UIColor+HuddleColors.h"
#import "SHVisitorClassPageViewController.h"
#import "SHVisitorProfileViewController.h"
#import "SHVisitorHuddleViewController.h"
#import "MBProgressHUD.h"

@interface SHSearchViewController ()<MBProgressHUDDelegate>

@property (nonatomic, strong) UISearchBar *searchedBar;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL shouldReloadOnAppear;

@property (strong, nonatomic) NSMutableArray *students;
@property (strong, nonatomic) NSMutableArray *huddles;
@property (strong, nonatomic) NSMutableArray *classes;

@end

BOOL beganSearch;

@implementation SHSearchViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Search";
        self.tabBarItem.image = [UIImage imageNamed:@"NavSearch.png"];
        [self.searchedBar setTintColor:[UIColor huddleSilver]];
        
        self.parseClassName = @"dummy";
        
        self.pullToRefreshEnabled = NO;
        
        self.paginationEnabled = NO;
        
        self.objectsPerPage = 15;
        
        self.students = [[NSMutableArray alloc]init];
        self.huddles = [[NSMutableArray alloc]init];
        self.classes = [[NSMutableArray alloc]init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchedBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    
    [self.searchedBar setImage:[UIImage imageNamed:@"NavNavSearch.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    self.searchedBar.showsCancelButton = YES;
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    self.searchedBar.barTintColor = [UIColor huddleOrange];
    self.searchedBar.placeholder = @"Search";
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor huddleOrange]];
    self.searchedBar.layer.borderWidth = 1;
    self.searchedBar.layer.borderColor = [[UIColor huddleOrange] CGColor];
    self.searchedBar.delegate = self;
    self.tableView.tableHeaderView = self.searchedBar;
    
    [self.searchedBar becomeFirstResponder];
    
    
}



#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self doHeavySearchWith:searchText andHud:hud];
    });
}

-(void)doHeavySearchWith:(NSString*)searchText andHud: (MBProgressHUD*)hud
{
    beganSearch = true;
    
    //Clean up past search results
    [self.searchResults removeAllObjects];
    //[self.searchedBar resignFirstResponder];
    self.searchResults = [NSMutableArray arrayWithCapacity:20];
    
    [self.students removeAllObjects];
    [self.huddles removeAllObjects];
    [self.classes removeAllObjects];
    
    PFQuery *studentQuery = [PFUser query];
    studentQuery.cachePolicy =kPFCachePolicyCacheElseNetwork;
    [studentQuery whereKey:SHStudentLowerNameKey containsString:[searchText lowercaseString]];
    [studentQuery whereKey:SHStudentNameKey notEqualTo:[PFUser currentUser][SHStudentNameKey]];
    
    [self.students addObjectsFromArray:[studentQuery findObjects]];
    [self.searchResults addObjectsFromArray:self.students];
    
    PFQuery *huddleQuery = [PFQuery queryWithClassName:SHHuddleParseClass];
    huddleQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [huddleQuery whereKey:SHHuddleLowerName containsString:[searchText lowercaseString]];
    
    [self.huddles addObjectsFromArray:[huddleQuery findObjects]];
    [self.searchResults addObjectsFromArray:self.huddles];
    
    PFQuery *classQuery = [PFQuery queryWithClassName:SHClassParseClass];
    classQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [classQuery whereKey:SHClassUniqueName containsString:[searchText lowercaseString]];
    
    [self.classes addObjectsFromArray:[classQuery findObjects]];
    [self.searchResults addObjectsFromArray:self.classes];
    
    //[query orderByAscending:SHStudentLowerNameKey];
    
    [self loadObjects];
    
    [self.searchedBar becomeFirstResponder];
    [hud removeFromSuperview];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0)
        return SHStudentCellHeight;
    else if(indexPath.section == 1)
        return SHHuddleCellHeight;
    else
        return SHClassCellHeight;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(!beganSearch)
        return 0.0;
    
    if (section == 0 && [self.students count] > 0) {
        return 20.0;
    } else if (section == 1 && [self.huddles count] > 0) {
        return 20.0;
    } else if (section == 2 && [self.classes count] > 0) {
        return 20.0;
    } else
        return 0.0;

}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Students";
    } else if (section == 1) {
        return @"Huddles";
    } else {
        return @"Classes";
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchResults == nil) {
        return 0;
    } else if ([self.searchResults count] == 0 && section == 0) {
        return 1;
    } else {
        if (section == 0) {
            return [self.students count];
        } else if (section == 1) {
            return [self.huddles count];
        } else {
            return [self.classes count];
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NothingCellIdentifier = @"NothingCell";
    
    
    if ([self.searchResults count] == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NothingCellIdentifier];
        
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NothingCellIdentifier];
        
        cell.textLabel.text = @"No Results Found";
        cell.textLabel.textColor = [UIColor huddleSilver];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:15.0];
        
        return cell;
    }
    
    
    if(indexPath.section == 0)
    {
        PFUser *studentObject = self.students[indexPath.row];
        [studentObject fetchIfNeeded];
        
        SHStudentCell *cell = [tableView dequeueReusableCellWithIdentifier:SHStudentCellIdentifier];
        if(!cell)
            cell = [[SHStudentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SHStudentCellIdentifier];
        
        cell.delegate = self;
        
        [cell setStudent:studentObject];
        
        [cell layoutIfNeeded];
        
        return cell;
    }
    else if(indexPath.section == 1)
    {
        PFObject *huddleObject = self.huddles[indexPath.row];
        [huddleObject fetchIfNeeded];
        
        SHHuddleCell *cell = [tableView dequeueReusableCellWithIdentifier:SHHuddleCellIdentifier];
        if(!cell)
            cell = [[SHHuddleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SHHuddleCellIdentifier];
        
        cell.delegate = self;
        [cell setHuddle:huddleObject];
        
        [cell layoutIfNeeded];
        
        return cell;
    }
    else
    {
        PFObject *classObject = self.classes[indexPath.row];
        [classObject fetchIfNeeded];
        
        SHClassCell *cell = [tableView dequeueReusableCellWithIdentifier:SHClassCellIdentifier];
        if(!cell)
            cell = [[SHClassCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SHClassCellIdentifier];
        cell.delegate = self;
        
        [cell setClass:classObject];
        [cell layoutIfNeeded];
        
        return cell;
    }
    
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //$$%%
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchedBar resignFirstResponder];
    
    [self.searchedBar resignFirstResponder];
    
    if(indexPath.section == 0)
    {
        PFUser *studentObject = [self.students objectAtIndex:(int)indexPath.row];
        [studentObject fetchIfNeeded];
        
        SHVisitorProfileViewController *visitorStudentV = [[SHVisitorProfileViewController alloc]initWithStudent:studentObject];
        
        [self.navigationController pushViewController:visitorStudentV animated:YES];
    }
    else if(indexPath.section == 1)
    {
        PFObject *huddleObject = [self.huddles objectAtIndex:(int)indexPath.row];
        [huddleObject fetchIfNeeded];
        
        SHVisitorHuddleViewController *visitorHuddleVC = [[SHVisitorHuddleViewController alloc]initWithHuddle:huddleObject];
        
        [self.navigationController pushViewController:visitorHuddleVC animated:YES];
    }
    else
    {
        PFObject* classObject = [self.classes objectAtIndex:(int)indexPath.row];
        [classObject fetchIfNeeded];
        
        SHVisitorClassPageViewController *visitorClassVC = [[SHVisitorClassPageViewController alloc]initWithClass:classObject];
        
        [self.navigationController pushViewController:visitorClassVC animated:YES];
        
    }
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.searchResults count] == 0) {
        return nil;
    } else {
        return indexPath;
    }
}



@end
