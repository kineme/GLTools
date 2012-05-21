

@interface KinemeGLOrthoPatch : QCPatch
{
	QCBooleanPort	*inputBypass;
	QCNumberPort	*inputLeft;
	QCNumberPort	*inputRight;
	QCNumberPort	*inputBottom;
	QCNumberPort	*inputTop;
	QCNumberPort	*inputNear;
	QCNumberPort	*inputFar;	
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end