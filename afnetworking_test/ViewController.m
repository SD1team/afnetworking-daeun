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

@synthesize results, key, rowNo;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 100;
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"http://api.themoviedb.org/3/movie/now_playing?api_key=d74a7e1423e9267f335de909f5a25f84"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error || responseObject == nil) {
            NSLog(@"Error: %@", error);
        } else {
            
            results = [responseObject objectForKey:@"results"];
            
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
        
        //NSLog(@"self.date = %@", date);
       // NSLog(@"self.key = %@", self.key);
        
    }];
    
    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SectionsTableIdentifier];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500%@", [section objectForKey:@"poster_path"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"holder"]];
    
    /*
     NSURL *url = [NSURL URLWithString:urlString];
     NSData *data = [NSData dataWithContentsOfURL:url];
     UIImage *image = [[UIImage alloc] initWithData:data];
     cell.imageView.image = image;
     */
    
    cell.textLabel.text = [section objectForKey:@"title"];
    
    return cell;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 10)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string = self.key[section];//[list objectAtIndex:section];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor /*clearColor]*/colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDate* dateKey = self.key[indexPath.section];
    NSMutableArray* dataArry = [self.section objectForKey:dateKey];
    NSDictionary* section = [dataArry objectAtIndex:rowNo];

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Overview"
                                                   message:[section objectForKey:@"overview"]
                                                  delegate:self
                                         cancelButtonTitle:@"닫기"    /* nil 로 지정할 경우 cancel button 없음 */
                                         otherButtonTitles: nil];
    
    // alert창을 띄우는 method는 show이다.
    [alert show];

}

@end
