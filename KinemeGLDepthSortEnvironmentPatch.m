#import <OpenGL/CGLMacro.h>
#import "KinemeGLDepthSortEnvironmentPatch.h"
#import <KinemeGLRenderer.h>


static NSInteger KinemeGLDepthSortComparison(id<KinemeGLDepthRenderer> a, id<KinemeGLDepthRenderer> b, void *context)
{
    NSComparisonResult rc;
	
	if([a depth] < [b depth])
		rc = NSOrderedDescending;
	else
		rc = NSOrderedAscending;
	return rc;
}


@implementation KinemeGLDepthSortEnvironmentPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return kQCPatchExecutionModeConsumer;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return YES;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self=[super initWithIdentifier:fp8])
	{
//		[inputMode setMaxIndexValue: 1];
		[[self userInfo] setObject:@"Kineme GL Depth Sort Environment" forKey:@"name"];
	}
	
	return self;
}

-(BOOL)setup:(QCOpenGLContext*)context
{
	opaqueElements = [NSMutableArray new];
	transparentElements = [NSMutableArray new];
	return YES;
}

-(void)cleanup:(QCOpenGLContext*)context
{
	[opaqueElements release];
	[transparentElements release];
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	[self executeSubpatches:time arguments:arguments];

	id<KinemeGLDepthRenderer> e;

	[opaqueElements sortUsingFunction:KinemeGLDepthSortComparison context:nil];
	[transparentElements sortUsingFunction:KinemeGLDepthSortComparison context:nil];
	
	// Render Opaque elements near-to-far (minimize overdraw)
	for(e in opaqueElements)
		[e renderOnContext:context];

	// Render Transparent elements far-to-near (proper overlapping)
	for(e in [transparentElements reverseObjectEnumerator])
		[e renderOnContext:context];
	
	[opaqueElements removeAllObjects];
	[transparentElements removeAllObjects];

	return YES;
}


- (void)addElement:(id<KinemeGLDepthRenderer>)e isOpaque:(BOOL)opaque
{
	if(opaque)
		[opaqueElements addObject:e];
	else
		[transparentElements addObject:e];
}

@end
