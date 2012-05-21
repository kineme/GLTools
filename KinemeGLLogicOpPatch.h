

@interface KinemeGLLogicOpPatch : QCPatch
{
	QCIndexPort *inputMode;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end