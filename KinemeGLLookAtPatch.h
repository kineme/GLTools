

@interface KinemeGLLookAtPatch : QCPatch
{
	QCNumberPort	*inputEyeX;
	QCNumberPort	*inputEyeY;
	QCNumberPort	*inputEyeZ;
	
	QCNumberPort	*inputCenterX;
	QCNumberPort	*inputCenterY;
	QCNumberPort	*inputCenterZ;
	
	QCNumberPort	*inputUpX;
	QCNumberPort	*inputUpY;
	QCNumberPort	*inputUpZ;	
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end