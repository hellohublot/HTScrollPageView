//
//  HTViewController.m
//  HTScrollPageView
//
//  Created by hellohublot on 03/28/2018.
//  Copyright (c) 2018 hellohublot. All rights reserved.
//

#import "HTViewController.h"
#import <HTScrollPageView/HTScrollPageView.h>

@interface HTViewController () <HTScrollPageDelegate>

@property (nonatomic, strong) HTScrollPageView *scrollPageView;

@end

@implementation HTViewController

/*-------------------------------------/init /-----------------------------------*/

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initializeDataSource];
	[self initializeUserInterface];
}

- (void)initializeDataSource {
	
}

- (void)initializeUserInterface {
	[self.view addSubview:self.scrollPageView];
	[self.scrollPageView reloadData];
}

- (HTScrollPageView *)scrollPageView {
	if (!_scrollPageView) {
		_scrollPageView = [[HTScrollPageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
		_scrollPageView.delegate = self;
	}
	return _scrollPageView;
}

- (NSInteger)numberOfPageView:(HTScrollPageView *)pageView {
	return 5;
}

- (void)buttonInitPageView:(HTScrollPageView *)pageView button:(UIButton *)button {
	NSLog(@"%@\n", button);
	button.backgroundColor = [UIColor orangeColor];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitle:[NSString stringWithFormat:@"hello world 0"] forState:UIControlStateNormal];
}

- (void)buttonDisplayPageView:(HTScrollPageView *)pageView button:(UIButton *)button indexRow:(NSInteger)indexRow {
	NSLog(@"%@\n", button);
	[button setTitle:[NSString stringWithFormat:@"hello world %ld", indexRow] forState:UIControlStateNormal];
}

- (void)buttonSelectedPageView:(HTScrollPageView *)pageView button:(UIButton *)button indexPath:(NSInteger)indexRow {
	NSLog(@"点击了 %ld", indexRow);
}

/*-------------------------------------/ controller override /-----------------------------------*/

/*-------------------------------------/ controller leave /-----------------------------------*/


@end
