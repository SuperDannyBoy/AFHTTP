//
//  UpdateViewController.m
//  Demo
//
//  Created by SuperDanny on 15/5/6.
//  Copyright (c) 2015年 Danny_Changhui. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"AFHTTP_Demo";
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2.0, 100, 100, 40)];
    btn1.backgroundColor = [UIColor grayColor];
    [btn1 setTitle:@"download" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(Download) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2.0, CGRectGetMaxY(btn1.frame)+100, 100, 40)];
    btn2.backgroundColor = [UIColor grayColor];
    [btn2 setTitle:@"update" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(Update) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2.0, CGRectGetMaxY(btn2.frame)+100, 100, 40)];
    btn3.backgroundColor = [UIColor grayColor];
    [btn3 setTitle:@"suspend" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(Suspend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    UIButton *btn4 = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2.0, CGRectGetMaxY(btn3.frame)+100, 100, 40)];
    btn4.backgroundColor = [UIColor grayColor];
    [btn4 setTitle:@"resume" forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(Resume) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
}

- (void)Update {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Update" ofType:@"jpg"];
    
    [[AFHTTP shareInstanced] sendRequest:@"http://example.com/upload"
                              parameters:nil
                          fileDictionary:AFHTTP_FileDic(filePath, @"file")
                                userInfo:AFHTTP_UserInfo(@"http://example.com/upload")
                                withType:request_Upload
                               isShowHUD:YES
                            SuccessBlock:^(id responseObject) {
                                DLog(@"Success");
                            }
                            FailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                DLog(@"Failure");
                            }];
}

- (void)Download {
    [[AFHTTP shareInstanced] sendRequest:@"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/121561682/1215597221431910861128.mp3?xcode=a41a35a64d9aa8d520b9975ff4796f4f43ec81f0f73d4ad3&song_id=121559722"
                              parameters:nil
                          fileDictionary:nil
                                userInfo:AFHTTP_UserInfo(@"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/121561682/1215597221431910861128.mp3?xcode=a41a35a64d9aa8d520b9975ff4796f4f43ec81f0f73d4ad3&song_id=121559722")
                                withType:request_Download
                               isShowHUD:NO
                            SuccessBlock:^(id responseObject) {
                                DLog(@"Success");
                            }
                            FailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                DLog(@"Failure");
                            }];
}

- (void)Suspend {
    [[AFHTTP shareInstanced] suspendWithDescription:AFHTTP_UserInfo(@"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/121561682/1215597221431910861128.mp3?xcode=a41a35a64d9aa8d520b9975ff4796f4f43ec81f0f73d4ad3&song_id=121559722")];
}

- (void)Resume {
    [[AFHTTP shareInstanced] resumeWithDescription:AFHTTP_UserInfo(@"http://music.baidu.com/data/music/file?link=http://yinyueshiting.baidu.com/data2/music/121561682/1215597221431910861128.mp3?xcode=a41a35a64d9aa8d520b9975ff4796f4f43ec81f0f73d4ad3&song_id=121559722")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
