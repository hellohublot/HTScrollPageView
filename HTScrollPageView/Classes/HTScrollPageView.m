//
//  HTScrollPageView.m
//  HTScrollPageView
//
//  Created by hublot on 2018/3/28.
//

#import "HTScrollPageView.h"

@interface HTScrollPageView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray <UIButton *> *buttonArray;

@property (nonatomic, strong) NSMutableArray <NSNumber *> *displayIndexArray;

@property (nonatomic, strong) NSTimer *timer;

@end


@implementation HTScrollPageView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initializeDefaultConfigure];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self initializeDefaultConfigure];
	}
	return self;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		[self initializeDefaultConfigure];
	}
	return self;
}

- (void)initializeDefaultConfigure {
	self.autoScrollTimeInterval = 3.5;
}



- (void)reloadData {
	NSInteger numberOfRow = 0;
	if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfPageView:)]) {
		numberOfRow = [self.delegate numberOfPageView:self];
	}
	NSMutableArray *displayIndexArray = [@[] mutableCopy];
	for (NSInteger index = 0; index < numberOfRow; index ++) {
		NSNumber *number = @(index);
		[displayIndexArray addObject:number];
	}
	self.displayIndexArray = displayIndexArray;
	if (self.displayIndexArray.count == 1) {
		self.scrollView.scrollEnabled = false;
		NSNumber *number = @(0);
		[displayIndexArray addObject:number];
		number = @(0);
		[displayIndexArray addObject:number];
	} else if (self.displayIndexArray.count == 2) {
		self.scrollView.scrollEnabled = true;
		NSNumber *number = @(0);
		[displayIndexArray addObject:number];
		number = @(1);
		[displayIndexArray addObject:number];
	} else if (self.displayIndexArray.count >= 3) {
		self.scrollView.scrollEnabled = true;
	} else {
		return;
	}
	
	[self insertSubview:self.scrollView atIndex:0];
	CGFloat itemWidth = self.scrollView.bounds.size.width;
	CGFloat itemHeight = self.scrollView.bounds.size.height;
	
	HTScrollPageScrollDirection direction = self.scrollDirection;
	switch (direction) {
		case HTScrollPageDirectionHorizontal: {
			self.scrollView.contentSize = CGSizeMake(itemWidth * 3, itemHeight);
			self.scrollView.contentOffset = CGPointMake(itemWidth, 0);
			[self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger index, BOOL * _Nonnull stop) {
				button.frame = CGRectMake(index * itemWidth, 0, itemWidth, itemHeight);
				[self.scrollView addSubview:button];
			}];
			break;
		}
		case HTScrollPageDirectionVertical: {
			self.scrollView.contentSize = CGSizeMake(itemWidth, itemHeight * 3);
			self.scrollView.contentOffset = CGPointMake(0, itemHeight);
			[self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger index, BOOL * _Nonnull stop) {
				button.frame = CGRectMake(0, itemHeight * index, itemWidth, itemHeight);
				[self.scrollView addSubview:button];
			}];
			break;
		}
	}
	
	if (numberOfRow != 1) {
		
		[self configureButtonArray];
		
		[self willDisplayPage];
		
		[self handleSwipeToLast];
		
		[self.timer invalidate];
		if (self.autoScrollTimeInterval > 0) {
			self.timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(timerAutoScroll) userInfo:nil repeats:true];
			self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.autoScrollTimeInterval];
		}
		
	} else {
		
		[self configureButtonArray];
		
		[self willDisplayPage];
	}
	
}

- (void)timerAutoScroll {
	CGPoint autoScrollContentOffset = CGPointZero;
	HTScrollPageScrollDirection direction = self.scrollDirection;
	switch (direction) {
		case HTScrollPageDirectionHorizontal: {
			autoScrollContentOffset = CGPointMake(self.scrollView.bounds.size.width * 2, 0);
			break;
		}
		case HTScrollPageDirectionVertical: {
			autoScrollContentOffset = CGPointMake(0, self.scrollView.bounds.size.height * 2);
			break;
		}
	}
	[self.scrollView setContentOffset:autoScrollContentOffset animated:true];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	self.timer.fireDate = [NSDate distantFuture];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.autoScrollTimeInterval];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat offset = 0;
	CGFloat scrollSinglePageNeedOffset = 0;
	CGPoint resetContentOffset = CGPointZero;
	HTScrollPageScrollDirection direction = self.scrollDirection;
	switch (direction) {
		case HTScrollPageDirectionHorizontal: {
			offset = scrollView.contentOffset.x;
			scrollSinglePageNeedOffset = scrollView.bounds.size.width;
			resetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
			break;
		}
		case HTScrollPageDirectionVertical: {
			offset = scrollView.contentOffset.y;
			scrollSinglePageNeedOffset = scrollView.bounds.size.height;
			resetContentOffset = CGPointMake(0, scrollView.bounds.size.height);
			break;
		}
	}
	
	
	
	if (offset >= 2 * scrollSinglePageNeedOffset) {
		[self handleSwipeToFirst];
	} else if (offset <= 0) {
		[self handleSwipeToLast];
	} else {
		return;
	}
	scrollView.contentOffset = resetContentOffset;
}

- (void)handleSwipeToFirst {
	NSNumber *firstObject = self.displayIndexArray.firstObject;
	[self.displayIndexArray removeObjectAtIndex:0];
	[self.displayIndexArray addObject:firstObject];
	[self willDisplayPage];
	[self updateCurrentPage];
}

- (void)handleSwipeToLast {
	NSNumber *lastObject = self.displayIndexArray.lastObject;
	[self.displayIndexArray removeLastObject];
	[self.displayIndexArray insertObject:lastObject atIndex:0];
	[self willDisplayPage];
	[self updateCurrentPage];
}

- (void)willDisplayPage {
	if (self.delegate && [self.delegate respondsToSelector:@selector(buttonWillDisplayPageView:button:indexRow:)]) {
		for (NSNumber *number in @[@0, @1, @2]) {
			NSInteger index = number.integerValue;
			UIButton *button = self.buttonArray[index];
			NSInteger currentRow = self.displayIndexArray[index].integerValue;
			[self.delegate buttonWillDisplayPageView:self button:button indexRow:currentRow];
		}
	}
}

- (void)updateCurrentPage {
	if (self.delegate && [self.delegate respondsToSelector:@selector(buttonDidDisplayPageView:button:indexRow:)]) {
		UIButton *button = self.buttonArray[1];
		NSInteger currentRow = [[self.displayIndexArray objectAtIndex:1] integerValue];
		[self.delegate buttonDidDisplayPageView:self button:button indexRow:currentRow];
	}
}

- (void)configureButtonArray {
	if (self.delegate && [self.delegate respondsToSelector:@selector(buttonInitPageView:button:)]) {
		[self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger index, BOOL * _Nonnull stop) {
			[self.delegate buttonInitPageView:self button:button];
		}];
	}
}

- (void)didTapedWithButton:(UIButton *)button {
	if (self.delegate && [self.delegate respondsToSelector:@selector(buttonSelectedPageView:button:indexPath:)]) {
		NSInteger buttonIndex = [self.buttonArray indexOfObject:button];
		NSInteger displayIndex = [self.displayIndexArray[buttonIndex] integerValue];
		[self.delegate buttonSelectedPageView:self button:button indexPath:displayIndex];
	}
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	self.scrollView.frame = (CGRect){{0, 0}, frame.size};
	[self reloadData];
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];
	self.scrollView.frame = bounds;
	[self reloadData];
}

- (UIScrollView *)scrollView {
	if (!_scrollView) {
		_scrollView = [[UIScrollView alloc] init];
		_scrollView.pagingEnabled = true;
		_scrollView.showsVerticalScrollIndicator = false;
		_scrollView.showsHorizontalScrollIndicator = false;
		_scrollView.delegate = self;
		_scrollView.scrollsToTop = false;
	}
	return _scrollView;
}

- (NSArray <UIButton *> *)buttonArray {
	if (!_buttonArray) {
		NSMutableArray *buttonArray = [@[] mutableCopy];
		for (NSInteger index = 0; index < 3; index ++) {
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button addTarget:self action:@selector(didTapedWithButton:) forControlEvents:UIControlEventTouchUpInside];
			[buttonArray addObject:button];
		}
		_buttonArray = buttonArray;
	}
	return _buttonArray;
}

@end
