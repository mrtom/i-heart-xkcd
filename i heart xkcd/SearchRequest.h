//
//  SearchRequest.h
//  i heart xkcd
//
//  Created by Tom Elliott on 16/07/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchRequest : NSObject

- (void)searchWithQuery:(NSString *)query
                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end
