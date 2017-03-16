

#import <Foundation/Foundation.h>


@interface NSData (Base64Encoding)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)encodingBase64;

@end
