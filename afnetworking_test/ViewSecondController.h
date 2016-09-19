//
//  ViewSecondController.h
//  afnetworking_test
//
//  Created by iOS on 2016. 9. 8..
//  Copyright (c) 2016년 iOS. All rights reserved.
//

#ifndef afnetworking_test_ViewSecondController_h
#define afnetworking_test_ViewSecondController_h

#import <UIKit/UIKit.h>

@interface ViewSecondController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *secondTableView;

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

@property (copy, nonatomic) NSArray *popularityResults;
@property (nonatomic, retain) NSMutableDictionary* popularityDic;
@property (copy, nonatomic) NSMutableArray *popArr;


@end


#endif
