@interface KinemeGLStereoEnvironmentPatch : QCPatch
{
	QCBooleanPort	*inputBypass;

	QCNumberPort	*inputZObject;
	QCNumberPort	*inputYFov;
	QCNumberPort	*inputZNear;
	QCNumberPort	*inputZScreen;
	QCNumberPort	*inputZFar;
	
	QCNumberPort	*inputIOD;

	QCIndexPort		*inputWidth;
	QCIndexPort		*inputHeight;


	QCImagePort		*outputImageLeft;
	QCImagePort		*outputImageRight;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end

