//
//  ViewController.m
//  XFZVideoPlayerView
//
//  Created by 黄勇 on 16/2/4.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "XFZVideoPlayerView.h"

@interface ViewController ()

@property(nonatomic,strong) XFZVideoPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerView = [[XFZVideoPlayerView alloc] init];
    self.playerView.backgroundColor = [UIColor blackColor];
    self.playerView.videoURL = [NSURL URLWithString:@"http://7xqenu.com1.z0.glb.clouddn.com/barbarbar.mp4"];
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(self.view.mas_width).multipliedBy(9.0f/16.0f);
    }];
}

@end
