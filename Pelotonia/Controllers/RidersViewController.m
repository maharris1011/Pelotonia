//
//  RidersViewController.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//
#import "AppDelegate.h"
#import "RidersViewController.h"
#import "RiderDataController.h"
#import "FindRiderViewController.h"
#import "ProfileTableViewController.h"
#import "AboutTableViewController.h"
#import "SearchViewController.h"
#import "Pelotonia-Colors.h"
#import "PelotoniaWeb.h"
#import "UIImage+Resize.h"
#import "MenuViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <AAPullToRefresh/AAPullToRefresh.h>


@interface RidersViewController ()

- (void)reloadTableData;

@end


@implementation RidersViewController {
    AAPullToRefresh *_tv;
}

@synthesize riderTableView = _riderTableView;
@synthesize riderSearchResults = _riderSearchResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up pull to refresh
    __weak RidersViewController *weakSelf = self;
    _tv = [self.tableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v) {
        [weakSelf refresh];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.5f];
    }];
    _tv.imageIcon = [UIImage imageNamed:@"PelotoniaBadge"];
    _tv.borderColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.translucent = YES;
    
    // set up the search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    // set up the search results
    self.riderSearchResults = [[NSMutableArray alloc] initWithCapacity:0];
        
}

- (void)viewDidUnload
{
    self.riderTableView = nil;
    [self setRiderTableView:nil];
    [self setRiderSearchResults:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTableData];
}

- (void)dealloc
{
    [self.tableView removeObserver:_tv forKeyPath:@"contentOffset"];
    [self.tableView removeObserver:_tv forKeyPath:@"contentSize"];
    [self.tableView removeObserver:_tv forKeyPath:@"frame"];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -- UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self filterContentForSearchText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
     
    [self.tableView reloadData];
}

#pragma mark -- pull to refresh view
- (void)refresh
{
    // update all riders in the list
    for (Rider *rider in [[AppDelegate sharedDataController] allRiders]) {
        [rider refreshFromWebOnComplete:^(Rider *rider) {
            [self reloadTableData];
        } onFailure:nil];
    }
}

- (void)reloadTableData
{
    NSSortDescriptor* desc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [[AppDelegate sharedDataController] sortRidersUsingDescriptors:[NSArray arrayWithObject:desc]];
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"prepareProfile:"]) {
        [self prepareProfile:(ProfileTableViewController *)segue.destinationViewController];
    }
    if ([segue.identifier isEqualToString:@"segueToFindRider"]) {
        FindRiderViewController *frvc = (FindRiderViewController *)segue.destinationViewController;
        frvc.delegate = self;
    }
}

- (void)prepareProfile:(ProfileTableViewController *)profileTableViewController
{
    Rider *rider = nil;
    if (self.searchController.active && ![self.searchController.searchBar.text  isEqual: @""]) {
        rider = [self.riderSearchResults objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        profileTableViewController.rider = rider;
    }
    else {
        rider = [[AppDelegate sharedDataController] objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        profileTableViewController.rider = rider;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active && ![self.searchController.searchBar.text  isEqual: @""] ) {
        // take us to the profile view
        [self performSegueWithIdentifier:@"prepareProfile:" sender:self];
    }
    else {
        // do nothing, this is handled by our segue in the storyboard
    }
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return the number of riders in our data source or in the search results
    if (self.searchController.active && ![self.searchController.searchBar.text  isEqual: @""]) {
        return [self.riderSearchResults count];
    }
    else {
        return [[AppDelegate sharedDataController] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // it's a "regular" cell
    static NSString *CellIdentifier = @"riderCell";
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (_cell == nil)
    {
        _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // this trick with the temporary variable silences the warning about capturing cell strongly in the block below
    __weak UITableViewCell *cell = _cell;
    
    // Configure the cell...
    Rider *rider = nil;
    if (self.searchController.active && ![self.searchController.searchBar.text  isEqual: @""]) {
        // we only have so much information in the search view
        rider = [self.riderSearchResults objectAtIndex:indexPath.row];
    }
    else {
        // looking at the "regular" view, so get rider info from our list of riders
        rider = [[AppDelegate sharedDataController] objectAtIndex:indexPath.row];
    }
    _cell.textLabel.textColor = PRIMARY_DARK_GRAY;
    _cell.textLabel.text = [NSString stringWithFormat:@"%@", rider.name];
    _cell.detailTextLabel.textColor = PRIMARY_GREEN;
    _cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",rider.route];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:rider.riderPhotoThumbUrl]
                   placeholderImage:[UIImage imageNamed:@"profile_default"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,
                                      NSURL *imageURL) {
        if (error) {
            NSLog(@"RidersViewController::cellforrowatindexpath error: %@",
                  error.localizedDescription);
        }
        [cell.imageView setImage:[image thumbnailImage:60 transparentBorder:1 cornerRadius:5 interpolationQuality:kCGInterpolationDefault]];
        
        [cell layoutSubviews];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    cell.textLabel.font = PELOTONIA_FONT(21);
    cell.detailTextLabel.font = PELOTONIA_FONT(15);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (self.searchController.active) {
        return NO;
    }
    else {
        return YES;
    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the dataController
        [[AppDelegate sharedDataController] removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    NSLog(@"Searching for content %@", searchText);
    
    // Update the filtered array based on the search text and scope.
    [self.riderSearchResults removeAllObjects];

    // search the list of riders for all matchine
    RiderDataController *dataController = [AppDelegate sharedDataController];
    NSArray *riders = [dataController allRiders];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    NSArray *searchResults = [riders filteredArrayUsingPredicate:resultPredicate];
    [self.riderSearchResults addObjectsFromArray:searchResults];
}


#pragma mark FindRiderViewControllerDelegate
- (void)findRiderViewControllerDidCancel:(FindRiderViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)findRiderViewControllerDidSelectRider:(FindRiderViewController *)controller rider:(Rider *)rider
{
    [controller dismissViewControllerAnimated:YES completion:nil];

    // add the current rider to the main list of riders
    RiderDataController *dataController = [AppDelegate sharedDataController];
    
    if (![dataController containsRider:rider]) {
        [dataController addObject:rider];
    }
    
    // save the database
    [dataController save];
    
}



@end
