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
}

- (void)Update {
    NSData *imageDate = [NSData data];
    UIImage *img = [UIImage imageNamed:@"Update.jpg"];
    NSString *fileType = @"png";
    if (UIImagePNGRepresentation(img)) {
        imageDate = UIImagePNGRepresentation(img);
    }
    else {
        imageDate = UIImageJPEGRepresentation(img, 1.0);
        fileType = @"jpg";
    }
    /*
    [[AFHTTP shareInstanced] sendRequest:@"http://example.com/upload"
                              parameters:nil
                          fileDictionary:AFHTTP_FileDic(imageDate, @"file", fileType)
                                userInfo:AFHTTP_UserInfo(@"http://example.com/upload")
                                withType:UPLOAD
                               isShowHUD:YES
                            SuccessBlock:^(id responseObject) {
                                DLog(@"Success");
                            }
                            FailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                DLog(@"Failure");
                            }];
    */
    [[AFHTTP shareInstanced] sendRequest:@"http://schat868.net:8500/AnXinService/Upload.action"
                              parameters:nil
                          fileDictionary:AFHTTP_FileDic(imageDate, @"myFile", fileType)
                                userInfo:AFHTTP_UserInfo(@"http://schat868.net:8500/AnXinService/Upload.action")
                                withType:UPLOAD
                               isShowHUD:NO
                            SuccessBlock:^(id responseObject) {
                                DLog(@"Success");
                            }
                            FailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                DLog(@"Failure");
                            }];
}

- (void)Download {
    [[AFHTTP shareInstanced] sendRequest:@"http://yinyueshiting.baidu.com/data2/music/121561682/121559722122400128.mp3?xcode=6ebac52c749779abab9902618e14e31143ec81f0f73d4ad3"
                              parameters:nil
                          fileDictionary:nil
                                userInfo:AFHTTP_UserInfo(@"http://yinyueshiting.baidu.com/data2/music/121561682/121559722122400128.mp3?xcode=6ebac52c749779abab9902618e14e31143ec81f0f73d4ad3")
                                withType:DOWNLOAD
                               isShowHUD:NO
                            SuccessBlock:^(id responseObject) {
                                DLog(@"Success");
                            }
                            FailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                DLog(@"Failure");
                            }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
