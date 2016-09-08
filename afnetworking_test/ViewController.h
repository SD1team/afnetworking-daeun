//
//  ViewController.h
//  afnetworking_test
//
//  Created by iOS on 2016. 9. 2..
//  Copyright (c) 2016년 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIRefreshControl *refreshControl;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) NSArray *results;
@property (copy, nonatomic) NSMutableArray *key;
@property (strong, nonatomic) NSMutableDictionary *section;

@property NSInteger rowNo;
@end