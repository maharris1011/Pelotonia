//
//  FeedbackViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 9/26/13.
//
//

#import "FeedbackViewController.h"
#import <Socialize/Socialize.h>

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    NSString *feedback = self.feedbackText.text;
    // send the feedback to support@isandlot.com
    [self sendFeedback:feedback];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editingDidEnd:(id)sender {
    UITextField *tfEmail = (UITextField *)sender;
    
    [self.doneButton setEnabled:[self isValidEmail:tfEmail.text]];
}

- (void)sendFeedback:(NSString *)feedback {

    NSString *username = [[SZUserUtils currentUser] userName];
    NSString *displayName = [[SZUserUtils currentUser] displayName];

    // Email Subject
    NSString *emailTitle = @"Pelotonia App Feedback";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"Name: %@\nUserName: %@\n%@", displayName, username, feedback];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"support@isandlot.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail] && mc)
    {
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller
           didFinishWithResult:(MFMailComposeResult)result
                         error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Feedback mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Feedback mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Feedback mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Feedback mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)isValidEmail: (NSString *)address
{
    NSString *someRegexp = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", someRegexp];
    return [emailTest evaluateWithObject:address];
}

@end
