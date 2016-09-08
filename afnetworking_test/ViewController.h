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

// UIRefreshControl 배경
@property (strong, nonatomic) UIView *refreshColorView;
// 로딩이미지의 투명배경
@property (strong, nonatomic) UIView *refreshLoadingView;
// 로딩이미지
@property (strong, nonatomic) UIImageView *loadingImg;
// 리프레싱 하고 있는지 여부
@property (assign) BOOL isRefreshAnimating;


@end