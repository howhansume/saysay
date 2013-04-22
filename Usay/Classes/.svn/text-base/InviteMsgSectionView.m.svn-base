//
//  InviteMsgSectionView.m
//  USayApp
//
//  Created by 1team on 10. 7. 8..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "InviteMsgSectionView.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation InviteMsgSectionView

@synthesize backgroundImageView, openImageView, groupTitleLabel, section;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		UIImage* strechImage = [[UIImage imageNamed:@"img_invitemsgsection.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
		
		UIImageView *_backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_backgroundImageView.image = strechImage;
		[self addSubview:_backgroundImageView];
		backgroundImageView = _backgroundImageView;

		UIImageView *_openImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9.0, (CGFloat)(self.frame.size.height - 16)/2+2, 13.0, 13.0)];
		_openImageView.backgroundColor = [UIColor clearColor];
		[self addSubview:_openImageView];
		openImageView = _openImageView;
		
		UILabel *_groupTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(26.0, 12.0, 200.0, 15.0)];
		_groupTitleLabel.textColor = ColorFromRGB(0x313736);
		_groupTitleLabel.font = [UIFont boldSystemFontOfSize:13.0];
		_groupTitleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_groupTitleLabel];
		groupTitleLabel = _groupTitleLabel;
	}

    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	if (backgroundImageView) {
		[backgroundImageView release];
		backgroundImageView = nil;
	}
	if (openImageView) {
		[openImageView release];
		openImageView = nil;
	}
	if (groupTitleLabel) {
		[groupTitleLabel release];
		groupTitleLabel = nil;
	}
    [super dealloc];
}


@end

/*
 내비게이션 컨트롤러의 스택 관리 메서드 네가지
 
 - pushViewController:animated: - 새로운 뷰 컨트롤러를 스택에 추가한다. 
 추가된 뷰 컨트롤러가 화면에 나타난다. 
 
 - popViewControllerAnimated: - 현재 뷰 컨트롤러를 제거하고 이전에 존재 하던 뷰 컨트롤러가 전면에 나타난다. 
 
 - popToRootViewControllerAnimated: - 루트 뷰 컨트롤러를 제외한 스택의 모든 뷰 컨트롤러를 제거한다. 루트 뷰 컨트롤러가 화면에 나타난다. 
 
 - popToViewController:animated: - 지정한 뷰 컨트롤러를 만날 때까지 스택의 뷰 컨트롤러들을 제거한다. 원하는 상위 단계로 곧바로 이동하고 싶을 때 사용한다. 

//*/