//
//  PostalCodeConverterAppDelegate.h
//  PostalCodeConverter
//
//  Created by Sidwyn Koh on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostalCodeConverterViewController;

@interface PostalCodeConverterAppDelegate : NSObject <UIApplicationDelegate> {

}
- (NSString *)stringWithUrl:(NSURL *)url;
- (id) objectWithUrl:(NSURL *)url;
- (void)runAll;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSMutableDictionary *data;

@property (nonatomic, retain) IBOutlet PostalCodeConverterViewController *viewController;

@end
