
#import "KinemeGLGridPatch.h"

@interface KinemeGLGridGeneratorPatch : QCPatch
{
	QCIndexPort		*inputHeight;
	QCIndexPort		*inputWidth;
	
	QCStructurePort	*outputGrid;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end