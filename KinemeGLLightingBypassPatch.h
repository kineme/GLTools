@interface KinemeGLLightingBypassPatch : QCPatch
{
	QCBooleanPort	*inputLightingBypass;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end