//
//  SearchRequest.m
//  i heart xkcd
//
//  Created by Tom Elliott on 16/07/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "SearchRequest.h"

#import <AFNetworking/AFNetworking.h>

/*
 
 XKCD Search API returns results like:
 
[
    {"num":"405","safe_title":"Journal 3"},
    {"num":"412","safe_title":"Startled"},
    {"num":"12","safe_title":"Poisson"},
    {"num":"455","safe_title":"Hats"}
 ]
 */

NSString *const SEARCH_API = @"http://iheartxkcd.com/search";

@implementation SearchRequest

- (void)searchWithQuery:(NSString *)query
                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    
    NSString *safeQuery = [self encodeToPercentEscapeString:query];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?q=%@", SEARCH_API, safeQuery]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:success
                                                                                        failure:failure];
    
    [operation start];

}

- (NSString*) encodeToPercentEscapeString:(NSString *)string
{
    return (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef) string,
                                            NULL,
                                            (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8));
}
@end
