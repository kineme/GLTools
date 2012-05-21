
#import "KinemeGLRenderer.h"


@interface KinemeGLDepthSortEnvironmentPatch : QCPatch
{
//	QCIndexPort	*inputMode;

	NSMutableArray *opaqueElements;
	NSMutableArray *transparentElements;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;

- (void)addElement:(id<KinemeGLDepthRenderer>)e isOpaque:(BOOL)opaque;
@end
