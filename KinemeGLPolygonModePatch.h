

@interface KinemeGLPolygonModePatch : QCPatch
{
	QCIndexPort		*inputFrontPolygonMode;	// Points, Lines, or Fills
	QCIndexPort		*inputBackPolygonMode;	// Points, Lines, or Fills

	QCNumberPort	*inputWidth;	// line width, for line mode
	QCBooleanPort	*inputAntialiasLines;	// line smoothing
	QCIndexPort		*inputStipplePattern;	// line stipple pattern
	QCIndexPort		*inputRepeatCount;	// stipple repeat, as per gl spec.
	QCNumberPort	*inputSize;		// point size, for point mode
	QCBooleanPort	*inputAntialiasPoints;	// point smoothing
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end