

@interface KinemeGLSplinePatch : QCPatch
{
	QCIndexPort		*inputSubdivisions;
	QCIndexPort		*inputStipple;
	QCIndexPort		*inputStippleScale;
	QCNumberPort	*inputTension;
	QCNumberPort	*inputWidth;
	QCBooleanPort	*inputShowPoints;
	QCBooleanPort	*inputShowSubdivisionPoints;
	QCNumberPort	*inputPointSize;
	QCBooleanPort	*inputUsePointColor;
	QCColorPort		*inputPointColor;
	QCOpenGLPort_Blending *inputBlending;
	QCOpenGLPort_ZBuffer *inputDepth;
	
	__strong QCNumberPort	**xArray;
	__strong QCNumberPort	**yArray;
	__strong QCNumberPort	**zArray;
	__strong QCColorPort		**colorArray;
	
	unsigned int controlPoints;
	__strong float *ptsx, *ptsy, *ptsz;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;

- (NSDictionary*)state;
- (BOOL)setState:(NSDictionary*)state;

- (void)addPoint;
- (void)removePoint;
@end