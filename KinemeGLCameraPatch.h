@interface KinemeGLCameraPatch : QCPatch
{
	QCNumberPort *inputXPosition;
	QCNumberPort *inputYPosition;
	QCNumberPort *inputZPosition;
	
	QCNumberPort *inputYaw;
	QCNumberPort *inputPitch;
	QCNumberPort *inputRoll;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end