//
//  PostalCodeConverterAppDelegate.m
//  PostalCodeConverter
//
//  Created by Sidwyn Koh on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PostalCodeConverterAppDelegate.h"

#import "PostalCodeConverterViewController.h"
#import "VTPG_Common.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"

@implementation PostalCodeConverterAppDelegate


@synthesize window=_window,data;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    //Initialise data
	NSString *Path = [[NSBundle mainBundle] bundlePath];
	NSString *DataPath = [Path stringByAppendingPathComponent:@"Data.plist"];
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithContentsOfFile:DataPath];
	self.data = tempDict;
	[tempDict release];
    
    //Main run
    [self runAll];
    
    LOG_EXPR(@"Complete.");
    
    return YES;
}

- (void)runAll{
    
    NSMutableDictionary *mhaDict = [self.data objectForKey:@"MHA"];
    
    for (NSString *eachDepartmentKey in mhaDict){
        NSArray *eachDepartment = [mhaDict objectForKey:eachDepartmentKey];
        for (NSMutableDictionary *eachSpecificDepartment in eachDepartment){
            NSString *theAddress = [eachSpecificDepartment objectForKey:@"Address"];
            NSRange range = [theAddress rangeOfString:@"Singapore"];
            NSString *thePostalCode = [theAddress substringWithRange:NSMakeRange(range.location+10,6)];
            LOG_EXPR(thePostalCode);
            
            NSString *toMakeUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=sg-%@",thePostalCode];
            id response = [self objectWithUrl:[NSURL URLWithString:toMakeUrl]];
            NSDictionary *feed = (NSDictionary *)response;
            NSString *extractLat = [[[[[feed objectForKey:@"Placemark"] objectAtIndex:0]objectForKey:@"Point"]objectForKey:@"coordinates"]objectAtIndex:1];
            NSString *extractLon = [[[[[feed objectForKey:@"Placemark"] objectAtIndex:0]objectForKey:@"Point"]objectForKey:@"coordinates"]objectAtIndex:0];

            [eachSpecificDepartment setObject:extractLat forKey:@"Latitude"];
            [eachSpecificDepartment setObject:extractLon forKey:@"Longitude"];
        }
    }
    
    [self.data setObject:mhaDict forKey:@"MHA"];
    
    //SAVE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"newData.plist"];
    [self.data writeToFile:path atomically:YES];
    
}

- (NSString *)grabURL:(NSURL *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSString *response = [request responseString];

    return response;
}

- (NSString *)stringWithUrl:(NSURL *)url
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:30];
    // Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
    
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}
- (id) objectWithUrl:(NSURL *)url
{
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSString *jsonString = [self grabURL:url];
    
	// Parse the JSON into an Object
	return [jsonParser objectWithString:jsonString error:NULL];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
