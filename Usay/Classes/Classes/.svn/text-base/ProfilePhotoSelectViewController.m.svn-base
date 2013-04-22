    //
//  ProfilePhotoSelectViewController.m
//  USayApp
//
//  Created by 1team on 10. 7. 23..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "ProfilePhotoSelectViewController.h"
#import "USayAppAppDelegate.h"

@interface ProfilePhotoSelectViewController (PrivateMethods)

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation ProfilePhotoSelectViewController

@synthesize currentPage;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(id) init 
{
	self = [super init];
	if(self != nil) {
		photoViewControllersArray = [NSMutableArray arrayWithCapacity:10];
	}
	return self;
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= [photoViewControllersArray count]) return;
	
//  // replace the placeholder if necessary
//    MyViewController *controller = [viewControllers objectAtIndex:page];
//    if ((NSNull *)controller == [NSNull null]) {
//        controller = [[MyViewController alloc] initWithPageNumber:page];
//        [viewControllers replaceObjectAtIndex:page withObject:controller];
//        [controller release];
//    }
//	
//    // add the controller's view to the scroll view
//    if (nil == controller.view.superview) {
//        CGRect frame = scrollView.frame;
//        frame.origin.x = frame.size.width * page;
//        frame.origin.y = 0;
//        controller.view.frame = frame;
//        [scrollView addSubview:controller.view];
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
 //   if (pageControlUsed) {
//        // do nothing - the scroll was initiated from the page control, not the user dragging
//        return;
//    }
//	
//    // Switch the indicator when more than 50% of the previous/next page is visible
//    CGFloat pageWidth = scrollView.frame.size.width;
//    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    pageControl.currentPage = page;
//	
//    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
//    [self loadScrollViewWithPage:page - 1];
//    [self loadScrollViewWithPage:page];
//    [self loadScrollViewWithPage:page + 1];
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}


-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (USayAppAppDelegate *)appDelegate {
	return [[UIApplication sharedApplication] delegate];
}

//*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentsView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentsView.backgroundColor = [UIColor whiteColor];
	scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 372)];
	[contentsView addSubview:scrollView];
	self.view = contentsView;
	[contentsView release];
}
//*/

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[leftButton release];
	self.navigationItem.rightBarButtonItem = nil;
	
	scrollView.pagingEnabled = YES;
	scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
	scrollView.scrollsToTop = NO;
	scrollView.delegate = self;
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [photoViewControllersArray count], scrollView.frame.size.height);
	currentPage = 1;

	self.title = [NSString stringWithFormat:@"사진 %i/%i", currentPage, [photoViewControllersArray count]];

    [super viewDidLoad];
}
//*/

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
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
