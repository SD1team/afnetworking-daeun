//
//  ViewController.m
//  afnetworking_test
//
//  Created by iOS on 2016. 9. 2..
//  Copyright (c) 2016년 iOS. All rights reserved.
//

#import "ViewController.h"

#import <AFNetworking/AFNetworking.h>


@interface ViewController ()

@end


static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";

@implementation ViewController

@synthesize results, key, rowNo, genreDataResults, genreDic;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 100;
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"http://api.themoviedb.org/3/movie/now_playing?api_key=d74a7e1423e9267f335de909f5a25f84"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id genreResponseObject, NSError *error) {
        if (error || genreResponseObject == nil) {
            NSLog(@"Error: %@", error);
        } else {
            
            results = [genreResponseObject objectForKey:@"results"];
            
            self.section = [NSMutableDictionary dictionary];
            self.key = [NSMutableArray array];
            
            [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SectionsTableIdentifier];
            
            
            for (NSDictionary *dic in results)
            {
                // Reduce event start date to date components (year, month, day)
                
                //NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                //[dateFormatter setDateFormat:@"yyyy-MM-dd"];
                //NSDate* date = [dateFormatter dateFromString:[dic objectForKey:@"release_date"]];
                
                NSDate* date = [dic objectForKey:@"release_date"];
                
                // If we don't yet have an array to hold the events for this day, create one
                NSMutableArray *eventsOnThisDay = [self.section objectForKey:date];
                if (eventsOnThisDay == nil) {
                    eventsOnThisDay = [NSMutableArray array];
                    
                    // Use the reduced date as dictionary key to later retrieve the event list this day
                    [self.section setObject:eventsOnThisDay forKey:date];
                }
                
                // Add the event to the list for this day
                [eventsOnThisDay addObject:dic];
            }
            NSArray *unsortedDays = [self.section allKeys];
            self.key = [NSMutableArray arrayWithArray:[unsortedDays sortedArrayUsingSelector:@selector(compare:)]];
            
        }
        
        [self.tableView reloadData];
        
    }];
    
    
    
    NSURL *genreURL = [NSURL URLWithString:@"http://api.themoviedb.org/3/genre/movie/list?api_key=d74a7e1423e9267f335de909f5a25f84"];
    NSURLRequest *genreRequest = [NSURLRequest requestWithURL:genreURL];

    NSURLSessionDataTask *genreDataTask = [manager dataTaskWithRequest:genreRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
       if (error || responseObject == nil)
       {
            NSLog(@"genreDataTask Error: %@", error);
       }
       else
       {
            genreDataResults = [responseObject objectForKey:@"genres"];
           
            self.genreDic = [[NSMutableDictionary alloc] init];
            for(NSDictionary* genre in genreDataResults)
            {
                [self.genreDic setObject:[genre objectForKey:@"name"] forKey:[genre objectForKey:@"id"]];
            }
        }
        
        [self.tableView reloadData];
        
    }];
    
    [dataTask resume];
    [genreDataTask resume];

    
    [self initCustomRefreshControl];
    
}


#pragma mark - PullToRefresh

/**
 * Custom RefreshControl 초기화
 */
- (void)initCustomRefreshControl {
    refreshControl = [[UIRefreshControl alloc] init];
    
    // UIRefreshControl 배경
    self.refreshColorView = [[UIView alloc] initWithFrame:refreshControl.bounds];
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.alpha = 0.30;
    
    // 로딩이미지의 투명배경
    self.refreshLoadingView = [[UIView alloc] initWithFrame:refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // 로딩 이미지
    self.loadingImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_favorite_18pt.png"]];
    
    [self.refreshLoadingView addSubview:self.loadingImg];
    self.refreshLoadingView.clipsToBounds = YES;
    
    // 기존 로딩이미지 icon 숨기기
    refreshControl.tintColor = [UIColor clearColor];
    
    [refreshControl addSubview:self.refreshColorView];
    [refreshControl addSubview:self.refreshLoadingView];
    
    self.isRefreshAnimating = NO;
    
    // 리프레시 이벤트 연결
    [refreshControl addTarget:self action:@selector(handleRefreshForCustom:) forControlEvents:UIControlEventValueChanged];
    
    [_tableView addSubview:refreshControl];
}

/**
 * 리프레시 이벤트 for Custom
 */
- (void)handleRefreshForCustom:(UIRefreshControl *)sender {
    
    // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
    // This is where you'll make requests to an API, reload data, or process information
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // When done requesting/reloading/processing invoke endRefreshing, to close the control
        [refreshControl endRefreshing];
    });
    // -- FINISHED SOMETHING AWESOME, WOO! --
}

/**
 * 테이블뷰 스크롤시 이벤트
 * 로딩이미지 위치 계산
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // RefreshControl 크기
    CGRect refreshBounds = refreshControl.bounds;
    
    // 테이블뷰 당겨진 거리 >= 0
    CGFloat pullDistance = MAX(0.0, - refreshControl.frame.origin.y);
    
    // 테이블뷰이 Width의 중간
    CGFloat midX = _tableView.frame.size.width / 2.0;
    
    // 로딩이미지 RefreshControl의 중간에 위치하도록 계산
    CGFloat loadingImgHeight = self.loadingImg.bounds.size.height;
    CGFloat loadingImgHeightHalf = loadingImgHeight / 2.0;
    
    CGFloat loadingImgWidth = self.loadingImg.bounds.size.width;
    CGFloat loadingImgWidthHalf = loadingImgWidth / 2.0;
    
    CGFloat loadingImgY = pullDistance / 2.0 - loadingImgHeightHalf;
    CGFloat loadingImgX = midX - loadingImgWidthHalf;
    
    CGRect loadingImgFrame = self.loadingImg.frame;
    loadingImgFrame.origin.x = loadingImgX;
    loadingImgFrame.origin.y = loadingImgY;
    
    self.loadingImg.frame = loadingImgFrame;
    
    refreshBounds.size.height = pullDistance;
    
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;
    
    if (refreshControl.isRefreshing && !self.isRefreshAnimating) {
        [self animateRefreshView];
    }
}

/**
 * 애니메이션
 * 로딩이미지 회전
 */
- (void)animateRefreshView {
    NSArray *colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor magentaColor]];
    static int colorIndex = 0;
    
    self.isRefreshAnimating = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // 로딩이미지 회전 by M_PI_2 = PI/2 = 90 degrees
                         [self.loadingImg setTransform:CGAffineTransformRotate(self.loadingImg.transform, M_PI_2)];
                         
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished) {
                         if (refreshControl.isRefreshing) {
                             [self animateRefreshView];
                         } else {
                             [self resetAnimation];
                         }
                     }];
}

/**
 * 애니메이션 중지
 */
- (void)resetAnimation {
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
}



/*
 // 레이아웃 초기화
 - (void)initLayout {
 [self initRefreshControl];
 [_tableView addSubview:refreshControl];
 }
 
 // RefreshControl 초기화
 
 - (void)initRefreshControl {
 refreshControl = [[UIRefreshControl alloc] init];
 [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
 
 refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull To Refresh"];
 }
 
 // Refresh 이벤트
 
 - (void)handleRefresh:(UIRefreshControl *)sender {
 NSLog(@">>> handleRefresh");
 [refreshControl endRefreshing];
 
 // refresh
 [_tableView reloadData];
 }
 
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
 }
 */


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return [self.key count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSDate *keys = key[section];
    NSMutableArray *dateSection = self.section[keys];
    return [dateSection count];
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.key[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
    
    NSDate* dateKey = self.key[indexPath.section];
    NSMutableArray* dataArry = [self.section objectForKey:dateKey];
    NSDictionary* section = [dataArry objectAtIndex:indexPath.row];
    
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SectionsTableIdentifier];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500%@", [section objectForKey:@"poster_path"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"holder"]];
    
 
    /*
     NSURL *url = [NSURL URLWithString:urlString];
     NSData *data = [NSData dataWithContentsOfURL:url];
     UIImage *image = [[UIImage alloc] initWithData:data];
     cell.imageView.image = image;
     */
    
    NSString* genreStr = @"GENRE: ";
    int cnt = 0;
    for(id gid in [section objectForKey:@"genre_ids"]) {
        cnt++;
        genreStr = [genreStr stringByAppendingFormat:@"%@", [self.genreDic objectForKey:gid]];
        if (cnt < [[section objectForKey:@"genre_ids"] count]) {
            genreStr = [genreStr stringByAppendingString:@", "];
        }
    }

    cell.textLabel.text = [section objectForKey:@"title"];
    cell.detailTextLabel.text = @"aa";//genreStr;
    
    return cell;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 20)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string = self.key[section];
    
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:187/255.0 green:227/255.0 blue:233/255.0 alpha:1.0]]; //your background color...

    //[self.tableView reloadData];
    return view;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //[self.tableView reloadData];
    return 20;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDate* dateKey = self.key[indexPath.section];
    NSMutableArray* dataArry = [self.section objectForKey:dateKey];
    NSDictionary* section = [dataArry objectAtIndex:rowNo];
    
    NSString* genreStr = @"GENRE: ";
    int cnt = 0;
    for(id gid in [section objectForKey:@"genre_ids"]) {
        cnt++;
        genreStr = [genreStr stringByAppendingFormat:@"%@", [self.genreDic objectForKey:gid]];
        if (cnt < [[section objectForKey:@"genre_ids"] count]) {
            genreStr = [genreStr stringByAppendingString:@", "];
        }
    }
    
    NSString* alertMsg = [NSString stringWithFormat:@"RELEASE DATE: %@\n\n%@\n\nOVERVIEW\n%@",
                          [section objectForKey:@"release_date"], genreStr, [section objectForKey:@"overview"]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[section objectForKey:@"title"]
                                                   message:alertMsg
                                                  delegate:self
                                         cancelButtonTitle:@"닫기"    //nil 로 지정할 경우 cancel button 없음
                                         otherButtonTitles: nil];
    
    // alert창을 띄우는 method는 show이다.
    [alert show];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDate* dateKey = self.key[indexPath.section];
        
        [self.section[dateKey] removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView reloadData];
    }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
