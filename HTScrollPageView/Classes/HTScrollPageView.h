//
//  HTScrollPageView.h
//  HTScrollPageView
//
//  Created by hublot on 2018/3/28.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HTScrollPageScrollDirection) {
	HTScrollPageDirectionHorizontal,
	HTScrollPageDirectionVertical
};

@class HTScrollPageView;

@protocol HTScrollPageDelegate <NSObject>

@required

- (NSInteger)numberOfPageView:(HTScrollPageView *)pageView;

- (void)buttonWillDisplayPageView:(HTScrollPageView *)pageView button:(UIButton *)button indexRow:(NSInteger)indexRow;

- (void)buttonDidDisplayPageView:(HTScrollPageView *)pageView button:(UIButton *)button indexRow:(NSInteger)indexRow;

@optional

- (void)buttonInitPageView:(HTScrollPageView *)pageView button:(UIButton *)button;

- (void)buttonSelectedPageView:(HTScrollPageView *)pageView button:(UIButton *)button indexPath:(NSInteger)indexRow;

@end

@interface HTScrollPageView : UIView

@property (nonatomic, assign) HTScrollPageScrollDirection scrollDirection;

@property (nonatomic, assign) NSInteger autoScrollTimeInterval;

@property (nonatomic, weak) id <HTScrollPageDelegate> delegate;

- (void)reloadData;


@end
