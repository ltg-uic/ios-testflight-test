//
//  TFTViewController.m
//  TFTest
//
//  Created by Aijaz Ansari on 3/3/14.
//  Copyright (c) 2014 Euclid Software, LLC. All rights reserved.
//

#import "TFTViewController.h"

// See http://stackoverflow.com/questions/3261763/accessing-the-value-of-a-preprocessor-macro-definition
// converting prepreocessor directive to nsstring
#define MACRO_VALUE(f)  MACRO_NAME(f)
#define MACRO_NAME(f) #f
#define MACRO_NSSTR(f) @""MACRO_VALUE(f)

#define xstr(s) str(s)
#define str(s) #s


@interface TFTViewController ()
    @property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TFTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.textView.text = MACRO_NSSTR(TF_TOKEN);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
