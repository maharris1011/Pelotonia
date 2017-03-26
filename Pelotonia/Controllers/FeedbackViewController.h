//
//  FeedbackViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 9/26/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FeedbackViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *feedbackText;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)editingDidEnd:(id)sender;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (weak, nonatomic) IBOutlet UITextField *userEmailAddress;

@end
