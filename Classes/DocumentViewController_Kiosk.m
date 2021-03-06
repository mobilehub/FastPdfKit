//
//  DocumentViewController_Kiosk.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "DocumentViewController_Kiosk.h"
#import "BookmarkViewController.h"
#import "OutlineViewController.h"
#import "MFDocumentManager.h"
#import "SearchViewController.h"
#import "TextDisplayViewController.h"
#import "SearchManager.h"
#import "MiniSearchView.h"
#import "mfprofile.h"

#define PAGE_NUM_LABEL_TEXT(x,y) [NSString stringWithFormat:@"%d/%d",(x),(y)]

@implementation DocumentViewController_Kiosk

@synthesize thumbSliderViewHorizontal,thumbsliderHorizontal;
@synthesize thumbImgArray;
@synthesize rollawayToolbar;

@synthesize searchBarButtonItem, changeModeBarButtonItem, zoomLockBarButtonItem, changeDirectionBarButtonItem, changeLeadBarButtonItem;
@synthesize bookmarkBarButtonItem, textBarButtonItem, numberOfPageTitleBarButtonItem, dismissBarButtonItem, outlineBarButtonItem;
@synthesize numberOfPageTitleToolbar;
@synthesize pageNumLabel;
@synthesize documentId;
@synthesize textDisplayViewController;
@synthesize searchViewController;
@synthesize searchManager;
@synthesize miniSearchView;
@synthesize pageSlider;

@synthesize imgModeSingle, imgModeDouble, imgZoomLock, imgZoomUnlock, imgl2r, imgr2l, imgLeadRight, imgLeadLeft;

-(void)dismissAllPopovers {
	
	// Utility method to quickly dispatch any poopover visible on screen.
	
	if (bookmarkViewVisible) {
		[bookmarkPopover dismissPopoverAnimated:YES];
		bookmarkViewVisible = NO;	
	}
	
	if (outlineViewVisible) {
		[outlinePopover dismissPopoverAnimated:YES];
		outlineViewVisible = NO;	
	}
	
	if (searchViewVisible) {
		[searchPopover dismissPopoverAnimated:YES];
		searchViewVisible = NO;
	}
	
	
	if (textViewVisible) {
		[textPopover dismissPopoverAnimated:YES];
		textViewVisible = NO;	
	}
}

#pragma mark -
#pragma mark ThumbnailSlider

-(IBAction) actionThumbnail:(id)sender{
	
	if (thumbsViewVisible) {
		[self hideHorizontalThumbnails];
	}else {
		[self showHorizontalThumbnails];
	}
}

-(void)showHorizontalThumbnails{
	if (thumbSliderViewHorizontal.frame.origin.y >= self.view.bounds.size.height) {
		//toolbar.hidden = NO;
		[UIView beginAnimations:@"show" context:NULL];
		[UIView setAnimationDuration:0.35];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[thumbSliderViewHorizontal setFrame:CGRectMake(0, thumbSliderViewHorizontal.frame.origin.y-thumbSliderViewHorizontal.frame.size.height, thumbSliderViewHorizontal.frame.size.width, thumbSliderViewHorizontal.frame.size.height)];
		[UIView commitAnimations];
		thumbsViewVisible = YES;
	}
}

-(void)hideHorizontalThumbnails {
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[thumbSliderViewHorizontal setFrame:CGRectMake(0, thumbSliderViewHorizontal.frame.origin.y+thumbSliderViewHorizontal.frame.size.height, thumbSliderViewHorizontal.frame.size.width, thumbSliderViewHorizontal.frame.size.height)];
	[UIView commitAnimations];
	thumbsViewVisible = NO;
}

#pragma mark -
#pragma mark TextDisplayViewController, _Delegate and _Actions

-(TextDisplayViewController *)textDisplayViewController {
	
	// Show the text display view controller to the user.
	
	if(nil == textDisplayViewController) {
		textDisplayViewController = [[TextDisplayViewController alloc]initWithNibName:@"TextDisplayView" bundle:[NSBundle mainBundle]];
		textDisplayViewController.documentManager = self.document;
	}
	
	return textDisplayViewController;
}

-(IBAction)actionText:(id)sender {
	
	if(!waitingForTextInput) {
		
		// We set the flag to YES and enable the documenter interaction. The flag is used to discard unwanted
		// user interaction on the document elsewhere, while the document interaction will allow the document
		// manager to notify its delegate (in this case itself) of user generated event on the document, like
		// the tap on a certain page.
		
		waitingForTextInput = YES;
		self.documentInteractionEnabled = YES;
		
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Text" message:@"Select the page you want the text of." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		senderText = sender;
		
	} else {
		waitingForTextInput = NO;
	}
	
}

#pragma mark -
#pragma mark BookmarkViewController, _Delegate and _Actions

-(void)dismissBookmarkViewController:(BookmarkViewController *)bvc {
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self dismissAllPopovers];
	}else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		bookmarkViewVisible = NO;
	}
}

-(void)bookmarkViewController:(BookmarkViewController *)bvc didRequestPage:(NSUInteger)page{
	self.page = page;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self dismissAllPopovers];
	} else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		bookmarkViewVisible = NO;
	}
}

-(IBAction) actionBookmarks:(id)sender {
	
		//
	//	We create an instance of the BookmarkViewController and push it onto the stack as a model view controller, but
	//	you can also push the controller with the navigation controller or use an UIActionSheet.
	
	if (bookmarkViewVisible) {
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			[bookmarkPopover dismissPopoverAnimated:YES];
			bookmarkViewVisible=NO;
			
		} else {
			
			[[self parentViewController]dismissModalViewControllerAnimated:YES];
			bookmarkViewVisible=NO;
		}
		
	}else {
		
		BookmarkViewController *bookmarksVC = [[BookmarkViewController alloc]initWithNibName:@"BookmarkView" bundle:[NSBundle mainBundle]];
		bookmarksVC.delegate = self;
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			[self dismissAllPopovers];
			
			bookmarkPopover = [[UIPopoverController alloc] initWithContentViewController:bookmarksVC];
			[bookmarkPopover setPopoverContentSize:CGSizeMake(372, 650)];
			[bookmarkPopover presentPopoverFromBarButtonItem:bookmarkBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			[bookmarkPopover setDelegate:self];
			
			bookmarkViewVisible=YES;
		}else {
			
			[self presentModalViewController:bookmarksVC animated:YES];
			bookmarkViewVisible=YES;
		}
		[bookmarksVC release];
	}
}


#pragma mark -
#pragma mark OutlineViewController, _Delegate and _Actions

-(void)dismissOutlineViewController:(OutlineViewController *)anOutlineViewController {
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		[self dismissAllPopovers];
		
	} else {
		
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		outlineViewVisible=NO;
	}
}

-(void)outlineViewController:(OutlineViewController *)ovc didRequestPage:(NSUInteger)page{
	self.page = page;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self dismissAllPopovers];
	}else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		outlineViewVisible=NO;
	}
}

-(IBAction) actionOutline:(id)sender {
	
	// We create an instance of the OutlineViewController and push it onto the stack like we did with the 
	// BookmarksViewController. However, you can show them in the same view with a segmented control, just
	// switch datasources and take it into account in the various tableView delegate methods. Another thing
	// to consider is that the view will be resetted once removed, and for an complex outline is not a nice thing.
	// So, it would be better to store the position in the outline somewhere to present it again the very same
	// view to the user or just retain the outlineVC and just let the application ditch only the view in case
	// of low memory warnings.
	
	
	if (outlineViewVisible) {
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			[outlinePopover dismissPopoverAnimated:YES];
			outlineViewVisible = NO;
		} else {
			
			[[self parentViewController]dismissModalViewControllerAnimated:YES];
			outlineViewVisible = NO;
		}
		
	} else {
		
		OutlineViewController *outlineVC = [[OutlineViewController alloc]initWithNibName:@"OutlineView" bundle:[NSBundle mainBundle]];
		[outlineVC setDelegate:self];
		
		// We set the inital entries, that is the top level ones as the initial one. You can save them by storing
		// this array and the openentries array somewhere and set them again before present the view to the user again.
		
		[outlineVC setOutlineEntries:[[self document] outline]];
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			[self dismissAllPopovers];	// Dismiss any eventual other popover.
			
			outlinePopover = [[UIPopoverController alloc] initWithContentViewController:outlineVC];
			[outlinePopover setPopoverContentSize:CGSizeMake(372, 650)];
			[outlinePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			[outlinePopover setDelegate:self];
			outlineViewVisible=YES;
			
		} else {
			
			[self presentModalViewController:outlineVC animated:YES];
			outlineViewVisible=YES;
			
		}
		[outlineVC release];
	}
}
	
#pragma mark -
#pragma mark SearchViewController, _Delegate and _Action

-(void)presentFullSearchView {
	
	// Get the full search view controller lazily, set it upt as the delegate for
	// the search manager and present it to the user modally.
	
	SearchManager * manager = nil;
	SearchViewController * controller = nil;
	
	
	// Get the search manager lazily and set up the document.
	
	manager = self.searchManager;
	manager.document = self.document;
	
	
	// Get the search view controller lazily, set the delegate at self to handle
	// document action and the search manager as data source.
	
	controller = self.searchViewController;
	[controller setDelegate:self];
	controller.searchManager = manager;
	
	// Enable overlay and set the search manager as the data source for
	// overlay items.
	[self addOverlayDataSource:searchManager];
	self.overlayEnabled = YES;
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		searchPopover = [[UIPopoverController alloc] initWithContentViewController:(UIViewController *)controller];
		[searchPopover setPopoverContentSize:CGSizeMake(450, 650)];
		[searchPopover setDelegate:self];
		[searchPopover presentPopoverFromBarButtonItem:searchBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
		searchViewVisible = YES;
		
	} else {
		
		[self presentModalViewController:(UIViewController *)controller animated:YES];
		searchViewVisible = YES;
	}	
}

-(void)presentMiniSearchViewWithStartingItem:(MFTextItem *)item {
	
	// This could be rather tricky.
	
	// This method is called only when the (Full) SearchViewController. It first instantiate the
	// mini search view if necessary, then set the mini search view as the delegate for the current
	// search manager - associated until now to the full SVC - then present it to the user.
	
	if(miniSearchView == nil) {
		
		// If nil, allocate and initialize it.
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			self.miniSearchView = [[MiniSearchView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-320)/2, -45, 320, 44)];
			[miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
			
		}else {
			self.miniSearchView = [[MiniSearchView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-320)/2, -45, 320, 44)];
			[miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
		}
		
	} else {
		
		// If not nil, remove it from the superview.
		if([miniSearchView superview]!=nil)
			[miniSearchView removeFromSuperview];
	}
	
	// Set up the connections.
	miniSearchView.dataSource = self.searchManager;
    [self addOverlayDataSource:self.searchManager];
    
	miniSearchView.documentDelegate = self;
	
	// Update the view with the right index.
	[miniSearchView reloadData];
	[miniSearchView setCurrentTextItem:item];
	
	// Add the subview and referesh the superview.
	[[self view]addSubview:miniSearchView];
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2, 50, 320, 44)];
		[self.view bringSubviewToFront:rollawayToolbar];
	}else {
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2, 50, 320, 44)];
		[self.view bringSubviewToFront:rollawayToolbar];
	}
	[UIView commitAnimations];
	
	miniSearchViewVisible = YES;
	
	[[self view]setNeedsLayout];
}

-(SearchViewController *)searchViewController {
	
	// Lazily allocation when required.
	
	if(nil==searchViewController) {
		
		// We use different xib on iPhone and iPad.
		
		BOOL isPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
		isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
		if(isPad) {
			searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView2_pad" bundle:[NSBundle mainBundle]];
		} else {
			searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView2_phone" bundle:[NSBundle mainBundle]];
		}
	}
	
	return searchViewController;
}

-(IBAction)actionSearch:(id)sender {
	
	// Get the instance of the Search Manager lazily and then present a full sized search view controller
	// to the user. The full search view controller will allow the user to type in a search term and
	// start the search. Look at the details in the utility method implementation.
	
	[self presentFullSearchView];	// This method will take care of everything.
}

-(void)dismissMiniSearchView {
	
	// Remove from the superview and release the mini search view.
	
	// Animation.
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,-50 , 320, 44)];
	}else {
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,-50 , 320, 44)];
	}
	
	[UIView commitAnimations];
	
	searchViewVisible = NO;
	miniSearchViewVisible = NO;
    
	// Actual removal.
	if(miniSearchView!=nil) {
		
		[miniSearchView removeFromSuperview];
		MF_COCOA_RELEASE(miniSearchView);
	}
	
	[self removeOverlayDataSource:self.searchManager];
    [self reloadOverlay];
}

-(void)showMiniSearchView {
	
	// Remove from the superview and release the mini search view.
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,50 , 320, 44)];
	}else {
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,50 , 320, 44)];
	}
	
	searchViewVisible = NO;
	
	[UIView commitAnimations];
	
	
}

-(SearchManager *)searchManager {
	
	// Lazily allocate and instantiate the search manager.
	
	if(nil == searchManager) {
		
		searchManager = [[SearchManager alloc]init];
	}
	
	return searchManager;
}

-(void)revertToFullSearchView {
	
	// Dismiss the minimized view and present the full one.
	
	[self dismissMiniSearchView];
	[self presentFullSearchView];
}

-(void)switchToMiniSearchView:(MFTextItem *)item {
	
	// Dismiss the full view and present the minimized one.
	
	[self dismissSearchViewController:searchViewController];
	[self presentMiniSearchViewWithStartingItem:item];
}

-(void)dismissSearchViewController:(SearchViewController *)aSearchViewController {
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self dismissAllPopovers];
	} else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		searchViewVisible=NO;
	}
    
    [self removeOverlayDataSource:self.searchManager];
    [self reloadOverlay];
}

#pragma mark -
#pragma mark Actions

-(IBAction) actionDismiss:(id)sender {
	
	// For simplicity, the DocumentViewController will remove itself. If you need to pass some
	// values you can just set up a delegate and implement in a delegate method both the
	// removal of the DocumentViweController and the processing of the values.
	
	// Call this function to stop the worker threads and release the associated resources.
	pdfIsOpen = NO;
	[self cleanUp];
	
	//
	//	Just remove this controller from the navigation stack.
	[[self navigationController]popViewControllerAnimated:YES];	
	
	// Or, if presented as modalviewcontroller, tell the parent to dismiss it.
	// [[self parentViewController]dismissModalViewControllerAnimated:YES];
}

-(IBAction) actionPageSliderSlided:(id)sender {
	
	// When the user move the slider, we update the label.
	
	// Get the slider value.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	// Update the label.
	[pageNumLabel setText:PAGE_NUM_LABEL_TEXT(pageNumber,[[self document]numberOfPages])];
}

-(IBAction) actionPageSliderStopped:(id)sender {
	
	// Get the requested page number from the slider.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	// Go to the page.
	[self setPage:pageNumber];
}

-(IBAction)actionChangeMode:(id)sender {
	
	//
	//	Find the mode used by the documentviewcontroller and change it depending on you needs. In this example we can
	//	arbitrarly change from single to double, so we can immediatly call the setMode: selector. Always use selectors
	//	and do not access or change value directly to avoid inconsitencies in the internal state of the viewer.
	//	You can also use your own state variables or combination of states, check on them and then perform
	//	changes to the internal state of the viewer according to your own rules.
	
	MFDocumentMode mode = [self mode];
	
	if(mode == MFDocumentModeSingle) {
		[self setMode:MFDocumentModeDouble];
	} else if (mode == MFDocumentModeDouble) {
		[self setMode:MFDocumentModeSingle];
	}
}

-(IBAction)actionChangeLead:(id)sender {
	
	// Look at actionChangeMode:
	
	MFDocumentLead lead = [self lead];
	
	if(lead == MFDocumentLeadLeft) {
		[self setLead:MFDocumentLeadRight];
		
	} else if (lead == MFDocumentLeadRight) {
		[self setLead:MFDocumentLeadLeft];
		
	}
}

-(IBAction)actionChangeDirection:(id)sender {
	
	// Look at actionChangeMode:
	
	MFDocumentDirection direction = [self direction];
	
	if(direction == MFDocumentDirectionL2R) {
		[self setDirection:MFDocumentDirectionR2L];
		
	} else if (direction == MFDocumentDirectionR2L) {
		[self setDirection:MFDocumentDirectionL2R];
		
	}
}

-(void)actionChangeAutozoom:(id)sender {
	
	// If autozoom is enable, when the user move to a new page, the zoom will be restored as it
	// was on the last page.
	
	BOOL autozoom = [self autozoomOnPageChange];
	if(autozoom) {
		[self setAutozoomOnPageChange:NO];
		[zoomLockBarButtonItem setImage:imgZoomUnlock];
	} else {
		[self setAutozoomOnPageChange:YES];
		[zoomLockBarButtonItem setImage:imgZoomLock];
	}
}

-(void)actionChangeAutomode:(id)sender {
	
	// When automode is turned on, it will automatically change the mode to single page when in portrait
	// and double page when in landscape.
	
	BOOL automode = [self automodeOnRotation];
	if(automode) {
		[self setAutomodeOnRotation:NO];
	} else {
		[self setAutomodeOnRotation:YES];
	}
}


#pragma mark -
#pragma mark MFDocumentViewControllerDelegate methods implementation


// The nice things about delegate callbacks is that we can use them to update the UI when the internal status of
// the controller changes, rather than query or keep track of it when the user press a button. Just listen for
// the right event and update the UI accordingly.

-(void) documentViewController:(MFDocumentViewController *)dvc didGoToPage:(NSUInteger)page {
	
	//
	//	Page has changed, either by user input or an internal change upon an event: update the label and the 
	//	slider to reflect that. If you save the current page as a bookmark to it is a good idea to store the value
	//	in this callback.
	
	[pageNumLabel setText:PAGE_NUM_LABEL_TEXT(page,[[self document]numberOfPages])];
	
	[pageSlider setValue:[[NSNumber numberWithUnsignedInteger:page]floatValue] animated:YES];
	
	[thumbsliderHorizontal goToPage:page-1 animated:YES];
	
	[self setNumberOfPageToolbar];
	
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeModeTo:(MFDocumentMode)mode automatic:(BOOL)automatically {
	
	//
	//	The mode has changed, for example from single to double. Update the UI with the right title, image, etc for
	//	the right componenets: in this case a button.
	//	You can also choose to change/update the UI when the setter is called instead, just be sure that you keep track
	//	of the changes in your own variables and check for inconsitencies in the internal state somewhere in your code.
	
	if(mode == MFDocumentModeSingle) {
		[changeModeBarButtonItem setImage:imgModeSingle];
	} else if (mode == MFDocumentModeDouble) {
		[changeModeBarButtonItem setImage:imgModeDouble];
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeDirectionTo:(MFDocumentDirection)direction {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(direction == MFDocumentDirectionL2R) {
		
		[changeDirectionBarButtonItem setImage:imgl2r];
		
	} else if (direction == MFDocumentDirectionR2L) {
		
		[changeDirectionBarButtonItem setImage:imgr2l];
	}
	
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeLeadTo:(MFDocumentLead)lead {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(lead == MFDocumentLeadLeft) {
		
		[changeLeadBarButtonItem setImage:imgLeadLeft];
		
	} else if (lead == MFDocumentLeadRight) {
		
		[changeLeadBarButtonItem setImage:imgLeadRight];
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnPage:(NSUInteger)page atPoint:(CGPoint)point {
	
	
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		[self dismissAllPopovers];
	}
	
	if(waitingForTextInput) {
		
		waitingForTextInput = NO;
		
		// Get the text display controller lazily, set up the delegate that will provide the document (this instance)
		// and show it.
		
		if (textViewVisible) {
			
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				
				[textPopover dismissPopoverAnimated:YES];
				textViewVisible = NO;
			}
			
		} else {
			
			TextDisplayViewController *controller = self.textDisplayViewController;
			controller.delegate = self;
			[controller updateWithTextOfPage:page];
			
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				controller.modalPresentationStyle = UIModalPresentationFormSheet;
			}
			
			textViewVisible = YES;
			[self presentModalViewController:controller animated:YES];
		}
	}
}


-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapAtPoint:(CGPoint)point {
	
	// If the flag waitingForTextInput is enabled, we use the touch event to select the page. Otherwise,
	// we are free to use it to show/hide the selected HUD elements.
	
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		
		[self dismissAllPopovers];
	}
	
	
	if(!waitingForTextInput) {
		
		//	We are using this callback to selectively hide/unhide some UI components like the buttons.
		
		if(hudHidden) {
			
			[self showToolbar];
			[self showHorizontalThumbnails];
			
			[miniSearchView setHidden:NO];
			
			hudHidden = NO;
			
		} else {
			
			// Hide
			
			[self hideToolbar];
			[self hideHorizontalThumbnails];
			
			[miniSearchView setHidden:YES];
			
			hudHidden = YES;
		}
	}
}

#pragma mark -
#pragma mark UIViewController lifcecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	// Create the view of the right size. Keep into consideration height of the status bar and the navigation bar. If
	// you want to add a toolbar, use the navigation controller's one like you would with an UIImageView to not cover
	// the document.
	
	UIView * aView = nil;
	
	BOOL isPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
 	if(isPad) {
		aView = [[UIView alloc]initWithFrame:CGRectMake(0, 20 + 44, 768, 1024-20-44)];
	} else {
		aView = [[UIView alloc]initWithFrame:CGRectMake(0, 20 + 44, 320, 480-20-44)];
	}
	
	[aView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[aView setAutoresizesSubviews:YES];
	
	// Background color: a nice texture if available, otherwise plain gray.
	
	if ([UIColor respondsToSelector:@selector(scrollViewTexturedBackgroundColor)]) {
		[aView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	} else {
		[aView setBackgroundColor:[UIColor grayColor]];
	}
	
	[self setView:aView];
	
	[aView release];
}
-(void)prepareToolbar {
    
	toolbarHeight = 44;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // IPad.
		
		self.imgModeSingle = [UIImage imageNamed:@"changeModeSingle.png"];
		self.imgModeDouble = [UIImage imageNamed:@"changeModeDouble.png"];
		
		self.imgZoomLock =[UIImage imageNamed:@"zoomLock.png"];
		self.imgZoomUnlock =[UIImage imageNamed:@"zoomUnlock.png"];
		
		self.imgl2r =[UIImage imageNamed:@"direction_l2r.png"];
		self.imgr2l =[UIImage imageNamed:@"direction_r2l.png"];
		
		self.imgLeadRight =[UIImage imageNamed:@"pagelead.png"];
		self.imgLeadLeft =[UIImage imageNamed:@"pagelead.png"];
		
	} else { // IPhone.
		
		self.imgModeSingle =[UIImage imageNamed:@"changeModeSingle_phone.png"];
		self.imgModeDouble =[UIImage imageNamed:@"changeModeDouble_phone.png"];
		
		self.imgZoomLock =[UIImage imageNamed:@"zoomLock_phone.png"];
		self.imgZoomUnlock =[UIImage imageNamed:@"zoomUnlock_phone.png"];
		self.imgl2r =[UIImage imageNamed:@"direction_l2r_phone.png"];
		self.imgr2l =[UIImage imageNamed:@"direction_r2l_phone.png"];
		
		self.imgLeadRight =[UIImage imageNamed:@"pagelead_phone.png"];
		self.imgLeadLeft =[UIImage imageNamed:@"pagelead_phone.png"];
		
	}
	
	
	NSMutableArray * items = [[NSMutableArray alloc]init];	// This will be the containter for the bar button items.
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // Ipad.
		
		UIBarButtonItem * aBarButtonItem = nil;
		
		// Dismiss.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"X.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
		self.dismissBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Zoom lock.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgZoomUnlock style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		self.zoomLockBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change direction.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgl2r style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		self.changeDirectionBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change lead.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgLeadRight style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];
		self.changeLeadBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change mode.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgModeSingle style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
		self.changeModeBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Page number.
		
		UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
		
		aLabel.textAlignment = UITextAlignmentLeft;
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.shadowColor = [UIColor whiteColor];
		aLabel.shadowOffset = CGSizeMake(0, 1);
		aLabel.textColor = [UIColor whiteColor];
		aLabel.font = [UIFont boldSystemFontOfSize:20.0];
		
		NSString *labelText = PAGE_NUM_LABEL_TEXT([self page],[[self document]numberOfPages]);		
		aLabel.text = labelText;
		self.pageNumLabel = aLabel;
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aLabel];
		self.numberOfPageTitleBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		[aLabel release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Search.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
		self.searchBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Text.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"text.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
		self.textBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Outline.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"indice.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
		
		[aBarButtonItem setWidth:60];
		self.outlineBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Bookmarks.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark_add.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		self.bookmarkBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
	} else { // Iphone.
		
		UIBarButtonItem * aBarButtonItem = nil;
		
		// Dismiss.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"X_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
		[aBarButtonItem setWidth:22];
		self.dismissBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[aBarButtonItem setWidth:25];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Zoom lock.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgZoomLock style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		[aBarButtonItem setWidth:22];
		self.zoomLockBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change direction.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgl2r style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		[aBarButtonItem setWidth:22];
		self.changeDirectionBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change lead.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgLeadRight style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];
		self.changeLeadBarButtonItem = aBarButtonItem;
		[aBarButtonItem setWidth:25];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change mode.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgModeSingle style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
		[aBarButtonItem setWidth:32];
		self.changeModeBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[aBarButtonItem setWidth:25];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Search.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
		[aBarButtonItem setWidth:22];
		self.searchBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Text.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"text_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
		[aBarButtonItem setWidth:22];
		self.textBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Outline.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"indice_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
		[aBarButtonItem setWidth:22];
		self.outlineBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Bookmarks.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark_add_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		[aBarButtonItem setWidth:25];
		self.bookmarkBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
	}
	
	
	UIToolbar * aToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -44, self.view.bounds.size.width, toolbarHeight)];
	aToolbar.hidden = YES;
	aToolbar.barStyle = UIBarStyleBlackTranslucent;
	[aToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
	[aToolbar setItems:items animated:NO];
	
	[self.view addSubview:aToolbar];
	
	self.rollawayToolbar = aToolbar;
	
	[aToolbar release];
	[items release];
	
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	// 
	//	Let the superclass do its stuff (setting up the views), then you can begin to add your own custom subviews
	//	like buttons.
	
	[super viewDidLoad];
	
	// A few flags.
	
	pdfIsOpen = YES;
	hudHidden=YES;
	bookmarkViewVisible = NO;
	outlineViewVisible = NO;
	miniSearchViewVisible = NO;
	
	// Slighty different font sizes on iPad and iPhone.
	
	UIFont *font = nil;
	
	BOOL isPad = NO;
	
#ifdef UI_USER_INTERFACE_IDIOM
	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
	
 	if(isPad) {
		font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	} else {
		font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	}
		
	CGFloat thumbSliderOffsetX = 0 ;
	CGFloat thumbSliderHeight = 0;
	CGFloat thumbSliderOffsetY = 0;
	CGFloat thumbSliderToolbarHeight= 0;
	
	UIView * aThumbSliderView = nil;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		// Initialize the thumb slider containter view. 
		
		aThumbSliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width,204)];
		thumbSliderToolbarHeight = 44; // Height of the thumb that include the slider.
		thumbSliderViewBorderWidth = 100;
		thumbSliderHeight = 20 ; // Height of the slider.
		
		thumbSliderOffsetY = aThumbSliderView.frame.size.height-44; // Vertical offset of the toolbar.
		thumbSliderOffsetX = thumbSliderOffsetY + 10; // Horizontal offset of the toolbar.
		
	} else {
		
		aThumbSliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 114)];
		thumbSliderToolbarHeight = 44;
		thumbSliderViewBorderWidth = 50;
		thumbSliderHeight = 10;
		thumbSliderOffsetY = aThumbSliderView.frame.size.height-44;
		thumbSliderOffsetX = thumbSliderOffsetY + 10;
		
	}
	
	
	[aThumbSliderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
	[aThumbSliderView setAutoresizesSubviews:YES];
	[aThumbSliderView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
	
	UIToolbar *aThumbSliderToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, thumbSliderOffsetY, self.view.frame.size.width, thumbSliderToolbarHeight)];
	[aThumbSliderToolbar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
	aThumbSliderToolbar.barStyle = UIBarStyleBlackTranslucent;
	
	[aThumbSliderView addSubview:aThumbSliderToolbar];
	[aThumbSliderToolbar release];
	
	int paddingSlider = 0;
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		paddingSlider = 10;
	}
	
	
	//Page slider.
	UISlider *aSlider = [[UISlider alloc]initWithFrame:CGRectMake((thumbSliderViewBorderWidth/2)-paddingSlider, thumbSliderOffsetX, aThumbSliderView.frame.size.width-thumbSliderViewBorderWidth-(paddingSlider*2),thumbSliderHeight)];
	[aSlider setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
	[aSlider setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
	[aSlider setMinimumValue:1.0];
	[aSlider setMaximumValue:[[self document] numberOfPages]];
	[aSlider setContinuous:YES];
	[aSlider addTarget:self action:@selector(actionPageSliderSlided:) forControlEvents:UIControlEventValueChanged];
	[aSlider addTarget:self action:@selector(actionPageSliderStopped:) forControlEvents:UIControlEventTouchUpInside];
	
	[self setPageSlider:aSlider];
	
	[aThumbSliderView addSubview:aSlider];
	
	[aSlider release];
	
	
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		
		// Set the number of page into the toolbar at the right the slider on iPhone.
		UILabel * aLabel = [[UILabel alloc]initWithFrame:CGRectMake((thumbSliderViewBorderWidth/2)+(aThumbSliderView.frame.size.width-thumbSliderViewBorderWidth)-25, thumbSliderOffsetX+6, 55, thumbSliderHeight)];
		[aLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
		aLabel.text = PAGE_NUM_LABEL_TEXT([self page],[[self document]numberOfPages]);
		aLabel.textAlignment = UITextAlignmentCenter;
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.textColor = [UIColor whiteColor];
		aLabel.font = [UIFont boldSystemFontOfSize:11.0];
		[aThumbSliderView addSubview:aLabel];
		self.pageNumLabel = aLabel;
		[aLabel release];
	}
	
	[self.view addSubview:aThumbSliderView];
	
	self.thumbSliderViewHorizontal = aThumbSliderView;
	
	[aThumbSliderView release];
	
	
	// Now prepare an image array to display as placeholder for the thumbs.
	
	NSMutableArray * aThumbImgArray  = [[NSMutableArray alloc]init];
	
	NSUInteger pagesCount = [[self document]numberOfPages];
	
	for (int i=0; i<pagesCount ; i++) {
		[aThumbImgArray insertObject:[NSNull null] atIndex:i];
	}	
	
	self.thumbImgArray = aThumbImgArray;
	
	[aThumbImgArray release];
	
	// Utility method to prepare the rollaway toolbar.
	
	[self prepareToolbar];
	
}


-(void)setNumberOfPageToolbar{
	
	NSString *labelTitle = PAGE_NUM_LABEL_TEXT([self page],[[self document]numberOfPages]);
	self.pageNumLabel.text = labelTitle;
}

-(void)showToolbar {
	
	// Show toolbar, with animation.
	
	rollawayToolbar.hidden = NO;
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[rollawayToolbar setFrame:CGRectMake(0, 0, rollawayToolbar.frame.size.width, toolbarHeight)];
	[UIView commitAnimations];		
}

-(void)hideToolbar{
	
	// Hide the toolbar, with animation.	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[rollawayToolbar setFrame:CGRectMake(0, -toolbarHeight, rollawayToolbar.frame.size.width, toolbarHeight)];
	[UIView commitAnimations];
}

-(void)prepareThumbSlider {
	
	if(thumbsliderHorizontal)
		return;
	
	// Create the actual thumb slider controller. The controller view will be added manually to the view stack, so you need to call viewDidLoad esplicitely.
	
	MFHorizontalSlider * anHorizontalThumbSlider = nil;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		anHorizontalThumbSlider = [[MFHorizontalSlider alloc] initWithImages:thumbImgArray size:CGSizeMake(100, 124) width:self.view.bounds.size.width height:160 type:1 andFolderName:documentId];
		
		
	}	else {
		
		anHorizontalThumbSlider = [[MFHorizontalSlider alloc] initWithImages:thumbImgArray size:CGSizeMake(50, 64) width:self.view.frame.size.width height:70 type:1 andFolderName:documentId];
		
	}
	
	anHorizontalThumbSlider.delegate = self;
	
	self.thumbsliderHorizontal = anHorizontalThumbSlider;
	
	[self.thumbSliderViewHorizontal addSubview:thumbsliderHorizontal.view];
	
	[anHorizontalThumbSlider viewDidLoad];
	[anHorizontalThumbSlider release];
	
	// Start generating the thumbs in background.
	
	[self performSelectorInBackground:@selector(generateThumbInBackground:) withObject:self.documentId];
}


-(void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	[self prepareThumbSlider];
}


- (void)didTappedOnPage:(int)number ofType:(int)type withObject:(id)object{
	[self setPage:number];
}

- (void)didSelectedPage:(int)number ofType:(int)type withObject:(id)object{
}


-(void)generateThumbInBackground:(NSString *)thumbFolderName {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSFileManager * fileManager = nil;
	NSError **error = NULL;
	
	NSArray *paths = nil;
	NSString *documentsDirectory = nil;
	
	NSString * filename = nil;
	NSString * fullPathToFile = nil;
	
	CGImageRef thumbImage = NULL;
	UIImage * image = nil;
	NSData * imageData = nil;
	CGSize thumbSize = CGSizeMake(140, 182);
	
	NSUInteger count;
	
	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	documentsDirectory = [[paths objectAtIndex:0]stringByAppendingPathComponent:thumbFolderName];
	
	fileManager = [[NSFileManager alloc]init];
	[fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:error];
	
	count = [[self document]numberOfPages];
	for (int i=1; i<=count; i++) {
		
		filename = [NSString stringWithFormat:@"png%d.png",i];
		fullPathToFile = [documentsDirectory stringByAppendingPathComponent:filename];
		
		if((![fileManager fileExistsAtPath: fullPathToFile]) && pdfIsOpen) {
			
			thumbImage = [self.document createImageForThumbnailOfPageNumber:i ofSize:thumbSize andScale:1.0];
			image = [[UIImage alloc] initWithCGImage:thumbImage];
			imageData = UIImagePNGRepresentation(image);
			
			if (pdfIsOpen) {

				[fileManager createFileAtPath:fullPathToFile contents:imageData attributes:nil];

			}
			
			CGImageRelease(thumbImage);
			[image release];
		}
	}
	
	[fileManager release];
	[pool release];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager {
	
	//
	//	Here we call the superclass initWithDocumentManager passing the very same MFDocumentManager
	//	we used to initialize this class. However, since you probably want to track which document are
	//	handling to synchronize bookmarks and the like, you can easily use your own wrapper for the MFDocumentManager
	//	as long as you pass an instance of it to the superclass initializer.
	
	if((self = [super initWithDocumentManager:aDocumentManager])) {
		[self setDocumentDelegate:self];
	}
	return self;
}


- (void)didReceiveMemoryWarning {
	
	// Remember to call the super implementation, since MFDocumentViewController will use
	// memory warnings to clear up its rendering cache.
	
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
	[super viewDidUnload];
	
}

- (void)dealloc {
	
	[imgModeSingle release];
	[imgModeDouble release];
	[imgZoomLock release];
	[imgZoomUnlock release];
	[imgl2r release];
	[imgr2l release];
	[imgLeadRight release];
	[imgLeadLeft release];
	
	[rollawayToolbar release];
	
	[documentId release];
	
	[searchBarButtonItem release], searchBarButtonItem = nil;
	[zoomLockBarButtonItem release], zoomLockBarButtonItem = nil;
	[changeModeBarButtonItem release], changeModeBarButtonItem = nil;
	[changeDirectionBarButtonItem release], changeDirectionBarButtonItem = nil;
	[changeLeadBarButtonItem release], changeLeadBarButtonItem = nil;
	
	[numberOfPageTitleBarButtonItem release];
	
	[searchViewController release];
	[textDisplayViewController release];
	[miniSearchView release];
	[searchManager release];
	
	[thumbnailView release];
	[thumbImgArray release];
	
	[super dealloc];
}

@end
