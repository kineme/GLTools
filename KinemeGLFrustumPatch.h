

@interface KinemeGLFrustumPatch : QCPatch
{
	QCBooleanPort	*inputBypass;
	QCNumberPort	*inputLeft;
	QCNumberPort	*inputRight;
	QCNumberPort	*inputBottom;
	QCNumberPort	*inputTop;
	QCNumberPort	*inputNear;
	QCNumberPort	*inputFar;	

//	QCNumberPort	*inputTX;
//	QCNumberPort	*inputTY;
//	QCNumberPort	*inputTZ;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end