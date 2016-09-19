//
//  ViewSecondController.m
//  afnetworking_test
//
//  Created by iOS on 2016. 9. 8..
//  Copyright (c) 2016년 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ViewSecondController.h"
#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ViewSecondController ()

@end

static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";

@implementation ViewSecondController

@synthesize results, key, rowNo, popularityResults, popularityDic, popArr, secondTableView = _secondTableView;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *popularityURL = [NSURL URLWithString:@"http://api.themoviedb.org/3/movie/popular?api_key=d74a7e1423e9267f335de909f5a25f84"];
    
    NSURLRequest *popularityRequest = [NSURLRequest requestWithURL:popularityURL];
    
    NSURLSessionDataTask *popularityDataTask = [manager dataTaskWithRequest:popularityRequest completionHandler:^(NSURLResponse *response, id popularityResponseObject, NSError *error) {
        if (error || popularityResponseObject == nil)
        {
            NSLog(@"popularityTask Error: %@", error);
        }
        else
        {
            
            popularityResults = [popularityResponseObject objectForKey:@"results"];
            
            self.popArr = [NSMutableArray array];
            
            [self.secondTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SectionsTableIdentifier];
            
            for(NSDictionary* popularity in popularityResults)
            {
                [self.popArr addObject:popularity];
                NSLog(@"pop arr = %@", popArr);
            }
        }
        
        [_secondTableView reloadData];
        
    }];
    
    [popularityDataTask resume];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.popArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
    
    NSDictionary* movie = [self.popArr objectAtIndex:indexPath.row];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SectionsTableIdentifier];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500%@", [movie objectForKey:@"poster_path"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"holder"]];
    
    NSLog(@"@b");
    
    cell.textLabel.text = [movie objectForKey:@"title"];
    
    return cell;
}

@end
