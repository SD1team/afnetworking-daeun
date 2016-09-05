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

@implementation ViewController

@synthesize results;


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
            //NSLog(@"%@ %@", response, responseObject);
            
        
            //이부분은 불필요 합니다.
            //initWithSessionConfiguration부분을 잘 살펴보세요.
            
//            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:&error];
//            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            results = [responseObject objectForKey:@"results"];
            
            [self.tableView reloadData];
            
            for (id dic in results)
            {
                //NSLog(@"poster_path = %@", [dic objectForKey:@"poster_path"]);
                NSLog(@"title = %@", [dic objectForKey:@"title"]);
            }
      
        }
    }];
    
    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"count = %d", [results count]);
    return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
    }
    
    NSDictionary *dic = [results objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"title"];
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500%@", [dic objectForKey:@"poster_path"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"holder"]];
    
    /*
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    cell.imageView.image = image;
    */
    
    return cell;

}

@end
