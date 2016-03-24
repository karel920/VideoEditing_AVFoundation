//
//  PHSideMenuViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/19/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHSideMenuViewController.h"
@interface PHSideMenuViewController()

@property (strong, nonatomic) NSArray *menu;
@property (strong, nonatomic) UINavigationBar *navBar;
//@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PHSideMenuViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
    //_menuTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //_menuNavigationViewController = [[UINavigationController alloc] init];
    [self configureCancelButton];
    //_tableView.delegate = self;
    //_tableView.dataSource = self;
    //[_tableView setFrame:CGRectMake(60.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    //[self.view addSubview:_tableView];
    NSString *cellIdentifier = @"settingsCellIdentifier";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

}

- (void) configureCancelButton
{
    //self.tableView.rowHeight = 100.0f;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    UIBarButtonItem *cancelButton;
    
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                 target:self
                                                                 action:@selector(cancelButtonTapped:)
                    ];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
//    [button addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UINavigationItem *cancelItem = [[UINavigationItem alloc] initWithTitle:@"More"];
    
    cancelItem.leftBarButtonItem = cancelButton;
    
    
    _navBar = [[UINavigationBar alloc] init];
    _navBar.items = [NSArray arrayWithObject:cancelItem];
    _navBar.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 60.0f);
    _navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navBar.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
//    self.navBar = _navBar;
    [self.view addSubview:_navBar];
    //[self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self setEdgesForExtendedLayout:UIRectEdgeTop];
    //self.tableView.hidden = YES;
    //self.tableView.frame = CGRectMake(0, _navBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)cancelButtonTapped:(UIBarButtonItem *)sender
{
    NSLog(@"Cancel Button tapped");
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableView Delegate & Datasource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 60.0f)];
    
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"settingsCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //UITableViewCell *cell = [[UITableViewCell alloc] init];//[tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Home";
            break;
            
        case 1:
            cell.textLabel.text = @"Profile";
            break;
            
        case 2:
            cell.textLabel.text = @"Settings";
            break;
            
        case 3:
            cell.textLabel.text = @"Sign Out";
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
    //                                                         bundle: nil];
    
    //UIViewController *vc ;
    
    switch (indexPath.row)
    {
        case 0:
            //vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
            break;
            
        case 1:
            //vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
            break;
            
        case 2:
            //vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendsViewController"];
            //[self dismissViewControllerAnimated:YES completion:nil];
            //[self.navigationController popToRootViewControllerAnimated:YES];
            break;
            
        case 3:
            //[self dismissViewControllerAnimated:YES completion:nil];
            //[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
           // [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
            //return;
            break;
    }
    // Dismiss menu for now.
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
    //                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
    //                                                                 andCompletion:nil];
}

@end


