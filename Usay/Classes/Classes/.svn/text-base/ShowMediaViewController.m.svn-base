//
//  ShowMediaViewController.m
//  USayApp
//
//  Created by 1team on 10. 7. 10..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "ShowMediaViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "USayAppAppDelegate.h"
#import "MessageInfo.h"
#import "CellMsgData.h"
#import "HttpAgent.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position
#import "USayDefine.h"

#define ID_PLAYBUTTON	9333
#define ID_PROGRESSVIEW	9334




@implementation ShowMediaViewController

@synthesize thumbnailImage, imageView, delayTimer, isPhotoView;
@synthesize httpAgent;
@synthesize downloadProgressView;
@synthesize originalPhotoUrl;
@synthesize originalMovieUrl;
@synthesize originalPhotoPath;
@synthesize originalMoviePath;
@synthesize chatSession;
@synthesize messageKey;
@synthesize isExit;

-(id)init
{
	self = [super init];
	if (self != nil) {
		thumbnailImage = nil;
		imageView = nil;

		delayTimer = nil;

		httpAgent = nil;
		
		downloadProgressView = nil;
		downloadActionSheet = nil;
		originalPhotoUrl = nil;
		originalMovieUrl = nil;
		
		originalPhotoPath = nil;
		originalMoviePath = nil;

		chatSession = nil;
		messageKey = nil;
		
		isPhotoView = YES;			// default 사진	
		isExit = NO;
	}

	return self;
}

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
	isExit = YES;
}

#pragma mark -
#pragma mark 앨범에 저장
-(void)savePictureToLibraryClicked
{
	if (isPhotoView) {
		@synchronized(imageView.image) {
			UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), self);
		}
	} else {
		if (originalMoviePath && [originalMoviePath length] > 0) {
			UISaveVideoAtPathToSavedPhotosAlbum(originalMoviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), self);
		}
	}
}

-(void)video:(NSString*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
	NSString *contents = @"동영상이 앨범으로 저장되었습니다.";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Usay주소록" message:contents delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
	[alert show];
	[alert release];
}

-(void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
	NSString *contents = @"사진이 앨범으로 저장되었습니다.";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Usay주소록" message:contents delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark 동영상 플레이
- (void) doMoviePlayer:(NSString *)filePath
{
	DebugLog(@"=====> doMoviePlayer path : %@", filePath);
	MPMoviePlayerController* moviePlayer = [[MPMoviePlayerController alloc] 
											initWithContentURL:[NSURL fileURLWithPath:filePath]];
	
	moviePlayer.scalingMode = MPMovieScalingModeAspectFit;		// 영상을 비율에 맞춰 화면에 모두 나올 수 있도록 맞춘다.
//	moviePlayer.movieControlMode = MPMovieControlModeHidden;	// 동영상 컨트롤러 히든. 기본값은 show.
	
	[moviePlayer play];
	
	// Register to receive a notification when the movie has finished playing
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) 
												 name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
}

- (void)moviePlayBack:(NSNotification *)notification 
{	
	NSString *movieFilePath = (NSString*)[notification object];
	
	if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 3.2) {		// iPhone OS 3.2 이상에서 실행
		MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:movieFilePath]];
		moviePlayer.view.backgroundColor = [UIColor blackColor];
		moviePlayer.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
		[self presentMoviePlayerViewControllerAnimated:moviePlayer];
	}
	else if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 3.2)		// iPhone OS 3.2 이하에서 실행
	{
		DebugLog(@"=====> moviePlayBack (< 3.2) path : %@", movieFilePath);
		[self doMoviePlayer:movieFilePath];
		/*
		MPMoviePlayerController* moviePlayer = [[[MPMoviePlayerController alloc] 
												 initWithContentURL:[NSURL fileURLWithPath:movieFilePath]] autorelease];
		moviePlayer.scalingMode = MPMovieScalingModeAspectFit;		// 영상을 비율에 맞춰 화면에 모두 나올 수 있도록 맞춘다.
		// 영상이 크면 작게, 작으면 크게해서 화면에 맞춤. 여백은 검은색으로 채운다.
//		moviePlayer.movieControlMode = MPMovieControlModeHidden;	// 동영상 컨트롤러 히든. 기본값은 show.
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
		[moviePlayer play];
		 */
	}
}

- (void)moviePlay:(id)sender
{		
	if (originalMoviePath && [originalMoviePath length] > 0)
	{
		if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 3.2)		// iPhone OS 3.2 이상에서 실행
		{
			DebugLog(@"=====> moviePlay (> 3.2) path : %@", originalMoviePath);
			MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:originalMoviePath]];
			moviePlayer.view.backgroundColor = [UIColor blackColor];
			moviePlayer.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
			[self presentMoviePlayerViewControllerAnimated:moviePlayer];
		}
		else if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 3.2)	// iPhone OS 3.2 이하에서 실행
		{
			DebugLog(@"=====> moviePlay (< 3.2) path : %@", originalMoviePath);
			[self doMoviePlayer:originalMoviePath];
			/*
			MPMoviePlayerController* moviePlayer = [[[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:originalMoviePath]] autorelease];
			moviePlayer.scalingMode = MPMovieScalingModeAspectFit;		// 영상을 비율에 맞춰 화면에 모두 나올 수 있도록 맞춘다.
			// 영상이 크면 작게, 작으면 크게해서 화면에 맞춤. 여백은 검은색으로 채운다.
			//		moviePlayer.movieControlMode = MPMovieControlModeHidden;	// 동영상 컨트롤러 히든. 기본값은 show.
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
			[moviePlayer play];
			 */
		}
	}
}

- (void)playbackDidFinish:(NSNotification *)notification 
{	
	if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 3.2)
	{
		MPMoviePlayerViewController *moviePlayer = [notification object];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
		[self dismissMoviePlayerViewControllerAnimated];
		//[moviePlayer release];
	}
	else if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 3.2)
	{
		MPMoviePlayerController *moviePlayer = [notification object];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
		[moviePlayer stop];
		[moviePlayer release];	// sochae 2010.10.18 - (주석 해지)
	}
}
#pragma mark -
#pragma mark 사진 다운로드
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    // Do something with the downloaded image
	imageView.image = image;
}

#pragma mark -
#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[actionSheet release];
	actionSheet = nil;
}

/**
 * Response 처리 
 **/
#pragma mark -
#pragma mark HttpAgent Delegate
- (void)connectionDidFinish:(HttpAgent*)aHttpAgent
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSString *resultData = [[[NSString alloc] initWithData:[aHttpAgent receivedData] encoding:NSUTF8StringEncoding] autorelease];	
	DebugLog(@"resultData = %@", resultData);

	if ((aHttpAgent.responseStatusCode / 100) == 2) {	// response OK!
		if (isPhotoView) {
			// 원본 이미지 show
			if (originalPhotoPath && [originalPhotoPath length] > 0) {
				BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:originalPhotoPath isDirectory:NO];
				if (exist) {
					NSLog(@"connectionDidFinish originalPhotoPath exist");
				}
				
				[imageView setImage:[UIImage imageWithContentsOfFile:originalPhotoPath]];
				
				// DB 추가
				[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set PHOTOFILEPATH=? where CHATSESSION=? and MESSAGEKEY=?", [originalPhotoPath lastPathComponent], chatSession, messageKey, nil];
				// 메모리 추가
				for (CellMsgData *msgData in [self appDelegate].msgArray) {
					if ([msgData.chatsession isEqualToString:chatSession] && [msgData.messagekey isEqualToString:messageKey]) {
						msgData.photoFilePath = [originalPhotoPath lastPathComponent];
						break;
					}
				}
			}
			
		} else {
			if (downloadActionSheet) {
				[downloadActionSheet dismissWithClickedButtonIndex:0 animated:YES];
			}
			if (originalMoviePath && [originalMoviePath length] > 0) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"moviePlayBack" object:originalMoviePath];
				
				// DB 추가
				[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set MOVIEFILEPATH=? where CHATSESSION=? and MESSAGEKEY=?", [originalMoviePath lastPathComponent], chatSession, messageKey, nil];
				// 메모리 추가
				for (CellMsgData *msgData in [self appDelegate].msgArray) {
					if ([msgData.chatsession isEqualToString:chatSession] && [msgData.messagekey isEqualToString:messageKey]) {
						msgData.movieFilePath = [originalMoviePath lastPathComponent];
						break;
					}
				}
			}
		}
	} else {
		// error
		if (downloadActionSheet) {
			[downloadActionSheet dismissWithClickedButtonIndex:0 animated:YES];
		}
	}
}

/**
 * fail 처리 
 **/
- (void)connectionDidFail:(HttpAgent*)aHttpAgent
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	DebugLog(@"connectionDidFinish responseStatusCode = %d", [aHttpAgent responseStatusCode]);
//	[downloadActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

/**
 * error일 경우 statusCode 200 번대 이외일 경우 에러 리턴
 **/
- (void)request:(HttpAgent*)aHttpAgent hadStatusCodeErrorWithResponse:(NSURLResponse *)aResponse
{
	DebugLog(@"ShowMediaViewController hadStatusCodeErrorWithResponse");
}

/**
 * download/upload 시 progress 처리
 **/
- (void)reloadProgress:(HttpAgent*)aHttpAgent Persent:(CGFloat)persent
{
	if (isPhotoView) {
		DebugLog(@"ShowMediaViewController reloadProgress exist");
	} else {
		// 0~100 으로 전송됨.
		if (downloadProgressView) {
			[downloadProgressView setProgress:(float)(persent/(float)100.0f)];
		} else {
			UIProgressView *progressView = (UIProgressView *)[self.view viewWithTag:ID_PROGRESSVIEW];
			if(progressView) {
				[progressView setProgress:(float)(persent/(float)100.0f)];
			}
		}
	}
}

#pragma mark -

- (void)loadView 
{
	//0913 kjh 수정
	//self.view가 로드가 안된다.. 윈도우 프레임으로 4인지 3인지 구분한다.
	USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
	
	
	DebugLog(@"=====> loadView size : %@", parentView.window.frame.size.width);
	
	//kjh 추가
	//DebugLog(@"self = %f", parentView.window.frame.size.width);
	//		NSLog(@"self.view = %@", self.view);
	
	DebugLog(@"======SHOW PRE===============");
	//CGRect rect = self.view.frame; //kjh 이유는 모르겠고 rect를 저렇게 잡으면 무한루프
	//	NSLog(@"self.view.frame = %@ self.view = %@", self.view.frame, self.view);
	
	
// 상태바 뺀다 3g는 20 4는 40
	CGRect rect;
	if(parentView.window.frame.size.width == 320)
		rect = CGRectMake(0, 0, parentView.window.frame.size.width, parentView.window.frame.size.height-20);
	else {
		rect = CGRectMake(0, 0, parentView.window.frame.size.width, parentView.window.frame.size.height-40);
		
	}
	
	
	// 320 == iphone 3g else iphone4
//	CGRect rect;
	//if(parentView.window.frame.size.width == 320)
	//	rect = parentView.window.frame;
	
	//rect	= CGRectMake(0, 0, 320, 460-44);
//	else
//		rect = parentView.window.frame;
	//	NSLog(@"======SHOW MEDIA VIEW %f=====", self.view.frame.size.width);
	
	// ~sochae
	
	UIImage* leftBarBtnImg = nil;
	UIImage* leftBarBtnSelImg = nil;
	UIImage* rightBarBtnImg = nil;
	UIImage* rightBarBtnSelImg = nil;
	if (rect.size.width < rect.size.height) {
		leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"btn_top_picturetolibrary_save.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_picturetolibrary_save_focus.png"];
	} else {
		leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_picturetolibrary_save.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_picturetolibrary_save_focus.png"];
	}
	
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[leftButton release];
	
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(savePictureToLibraryClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	if (isPhotoView)
	{
		// 사진 View
		UIView *contentsView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		contentsView.backgroundColor = [UIColor blackColor];
		self.view = contentsView;
		[contentsView release];
		
		imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.backgroundColor = [UIColor blackColor];
		[self.view addSubview:imageView];
	}
	else
	{
		// 동영상 Play
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBack:) name:@"moviePlayBack" object:nil];
		UIView *contentsView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
		contentsView.backgroundColor = [UIColor blackColor];
		self.view = contentsView;
		[contentsView release];
		
		UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[playBtn setImage:[UIImage imageNamed:@"playbutton.png"] forState:UIControlStateNormal];
		playBtn.frame = CGRectMake((self.view.frame.size.width-87.0f)/2.0f, (self.view.frame.size.height-87.0f)/2.0f-15.0f, 87.0f, 87.0f);
		[playBtn addTarget:self action:@selector(moviePlay:) forControlEvents:UIControlEventTouchUpInside];
		playBtn.backgroundColor = [UIColor clearColor];
		playBtn.tag = ID_PLAYBUTTON;
		playBtn.hidden = NO;
		[self.view addSubview:playBtn];
	}
	
	
	//종료
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (isPhotoView) {
		if ([UIApplication sharedApplication].statusBarHidden) {
			[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];	// UIStatusBarAnimationFade
		} else {
			[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
		}

		if (self.navigationController.navigationBar.hidden) {
			CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
			navigationBarFrame.origin.y = 20;
			self.navigationController.navigationBar.frame = navigationBarFrame;
			[self.navigationController.navigationBar setHidden:NO];
		} else {
			[self.navigationController.navigationBar setHidden:YES];
		}
	}
	[super touchesBegan:touches withEvent:event];
}

- (void)viewWillAppear:(BOOL)animated 
{
	if (isPhotoView) {
		self.navigationController.navigationBar.translucent = YES;
		self.navigationController.navigationBar.alpha = 0.7f;
		
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
		self.wantsFullScreenLayout = YES;
		
		if (originalPhotoPath && [originalPhotoPath length] > 0) {
			// 원본 이미지가 클경우를 대비해서 썸네일 우선 show 하고 타이머로 원본사진 show
//			imageView.image = thumbnailImage;
//			[imageView setImage:[UIImage imageWithContentsOfFile:originalPhotoPath]];
		} else {
			if (originalPhotoUrl && [originalPhotoUrl length] > 0) {
				imageView.image = thumbnailImage;
			} else {
				// error. 원본파일도 없고 다운받을수 있는 url도 없음.
				// 썸네일 이미지로만 show.
				imageView.image = thumbnailImage;
			}
		}
	} else {
		if (originalMoviePath && [originalMoviePath length] > 0) {
			// 원본 동영상 show
		} else {
			if (originalMovieUrl && [originalMovieUrl length] > 0) {
				// 원본 이미지 다운로드
			} else {
				// error. 원본파일도 없고 다운받을수 있는 url도 없음.
			}
		}
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	if (isPhotoView) {
		self.navigationController.navigationBar.translucent = NO;
		self.navigationController.navigationBar.alpha = 1.0f;

		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;	// UIStatusBarStyleDefault
		self.wantsFullScreenLayout = NO;
		
		if ([UIApplication sharedApplication].statusBarHidden) {
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
		} 
		
		if (self.navigationController.navigationBar.hidden) {
			[self.navigationController.navigationBar setHidden:NO];
		} 
	}
}

- (void)viewDidLoad
{
	
	
	
	
	
	if (isPhotoView) {
		if (originalPhotoPath && [originalPhotoPath length] > 0) {
			[imageView setImage:[UIImage imageWithContentsOfFile:originalPhotoPath]];
		} else {
			if (originalPhotoUrl && [originalPhotoUrl length] > 0) {

				self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
																 selector:@selector(originalPhotoDownload:) 
																 userInfo:nil repeats:NO];
			} else {
				// 썸네일 이미지로만 show.
				imageView.image = thumbnailImage;
			}
		}
	} else {
		if (originalMoviePath && [originalMoviePath length] > 0) {
			// 원본 동영상 show
			[[NSNotificationCenter defaultCenter] postNotificationName:@"moviePlayBack" object:originalMoviePath];
		} else {
			if (originalMovieUrl && [originalMovieUrl length] > 0) {
				self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
																 selector:@selector(originalMovieDownload:) 
																 userInfo:nil repeats:NO];
			} else {
				// error. 원본파일도 없고 다운받을수 있는 url도 없음.
			}
		}
	}
	
	[super viewDidLoad];
	
	
	
	
	
	
	
	
}

-(USayAppAppDelegate *)appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	switch (toInterfaceOrientation)  
    {  
        case UIDeviceOrientationPortrait: 
		{
			
		}
            break;  
        case UIDeviceOrientationLandscapeLeft:
		{
			
		}
            break;  
        case UIDeviceOrientationLandscapeRight:  
		{
			
		}
            break;  
        case UIDeviceOrientationPortraitUpsideDown:  
		{
			
		}
            break;  
		case UIDeviceOrientationFaceUp:
		{
			
		}
            break;  
		case UIDeviceOrientationFaceDown:
		{
			
		}
            break;  
		case UIDeviceOrientationUnknown:
		{	
			
		}
        default:  
            break;  
    }  
	
	//내비게이션 바 버튼 설정
	UIImage* leftBarBtnImg = nil;
	UIImage* leftBarBtnSelImg = nil;
	UIImage* rightBarBtnImg = nil;
	UIImage* rightBarBtnSelImg = nil;
	
	if (rect.size.width < rect.size.height) {
		leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"btn_top_picturetolibrary_save.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_picturetolibrary_save_focus.png"];
	} else {
		leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_picturetolibrary_save.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_picturetolibrary_save_focus.png"];	
	}

	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[leftButton release];
	
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(savePictureToLibraryClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
}

#pragma mark -
#pragma mark Timer 
-(void)originalImageShow:(NSTimer *)timecall
{
	[timecall invalidate];
	self.delayTimer = nil;
	
	[imageView setImage:[UIImage imageWithContentsOfFile:originalPhotoPath]];
}

-(void)originalMovieDownload:(NSTimer *)timecall
{
	[timecall invalidate];
	self.delayTimer = nil;

	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0007)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else {
		downloadActionSheet = [[[UIActionSheet alloc] initWithTitle:@"잠시만 기다려 주세요.\n동영상을 다운받는 중입니다.\n\n\n" 
														  delegate:self 
												 cancelButtonTitle:nil 
											destructiveButtonTitle:nil 
												 otherButtonTitles:nil] autorelease];
		downloadProgressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(50.0f, 70.0f, 220.0f, 90.0f)] autorelease];
		[downloadProgressView setProgressViewStyle:UIProgressViewStyleDefault];
		downloadProgressView.tag = ID_PROGRESSVIEW;
		[downloadProgressView setProgress:0.0f];
		[downloadActionSheet addSubview:downloadProgressView];
		[downloadActionSheet showInView:self.view];
		
		// TODO: 원본 동영상 다운로드
		httpAgent = [[HttpAgent alloc] init];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *cachesDirectory = [paths objectAtIndex:0];
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		if (originalMoviePath) {
			[originalMoviePath release];
			originalMoviePath = [[NSMutableString alloc] initWithString:[cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [[self appDelegate] generateUUIDString], @"MOV"]]];
		} else {
			originalMoviePath = [[NSMutableString alloc] initWithString:[cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [[self appDelegate] generateUUIDString], @"MOV"]]];
		}
		[pool release];
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[httpAgent requestDownloadUrl:originalMovieUrl filePath:originalMoviePath parent:self timeout:10];
	}
}

-(void)originalPhotoDownload:(NSTimer *)timecall
{
	[timecall invalidate];
	self.delayTimer = nil;

	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0008)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else {
		httpAgent = [[HttpAgent alloc] init];

		// TODO: 원본 이미지 다운로드
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		if (originalPhotoPath != nil) {
			[originalPhotoPath release];
			originalPhotoPath = nil;
		}
		originalPhotoPath = [[NSMutableString alloc] initWithString:(NSMutableString*)[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [[self appDelegate] generateUUIDString], @"jpg"]]];
		
		NSLog(@"originalPhotoPath = %@", originalPhotoPath);
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[httpAgent requestDownloadUrl:originalPhotoUrl filePath:originalPhotoPath parent:self timeout:10];
	}
}
#pragma mark -
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
//    NSLog(@"ShowMediaViewController didReceiveMemoryWarning");
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
//	NSLog(@"ShowMediaViewController viewDidUnload");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{	
	if (!isExit) {	// 파일 다운받고 dealloc 불리우는 현상 발상...ㅠㅠ. 실제 백버튼으로 나갈때만 dealloc 호출 되도록 처리
		return;
	}
	
	if (httpAgent) {
		if ([httpAgent isRequest]) {
			[httpAgent cancelRequest];
		}
		[httpAgent release];
		httpAgent = nil;
	}
	
	if (thumbnailImage) {
		[thumbnailImage release];
	}
	if (isPhotoView) {
		[imageView release];
		thumbnailImage = nil;
		imageView = nil;
	} else {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"moviePlayBack" object:nil];
	}

	if (originalPhotoUrl) {
		[originalPhotoUrl release];
		originalPhotoUrl = nil;
	}
	if (originalMovieUrl) {
		[originalMovieUrl release];
		originalMovieUrl = nil;
	}
	if (chatSession) {
		[chatSession release];
		chatSession = nil;
	}
	if (messageKey) {
		[messageKey release];
		messageKey = nil;
	}
	if (originalPhotoPath) {
		[originalPhotoPath release];
		originalPhotoPath = nil;
	}
	if (originalMoviePath) {
		[originalMoviePath release];
		originalMoviePath = nil;
	}
		
    [super dealloc];
}

@end
