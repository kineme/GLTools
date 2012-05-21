

@interface KinemeGLGridRendererPatch : QCPatch
{
	QCStructurePort *inputStructure;
	QCIndexPort		*inputWireFrame;
	QCIndexPort		*inputSelection;
	QCIndexPort		*inputSubdivisionAmount;
	QCBooleanPort	*inputHighlightSelection;
	
	QCColorPort *inputColor;
	
	QCOpenGLPort_Image	*inputImage;
	QCOpenGLPort_Blending *inputBlending;
	QCOpenGLPort_Culling *inputCulling;
	
	QCOpenGLPort_ZBuffer *inputDepth;
	
	GLuint gridList;
	
#if 0	// optimizations for higher density grids.  Not implemented yet.
	QCStructure	*currentStructure;
	unsigned int currentWidth, currentHeight;
	float *vertexData;	// x, y, z data
	float *colorData;	// r, g, b, a data
	float *texData;	// u, v data
#endif
}

- (id)initWithIdentifier:(id)fp8;

//- (id)setup:(QCOpenGLContext *)context;
//- (void)cleanup:(QCOpenGLContext *)context;

//- (void)enable:(QCOpenGLContext *)context;
//- (void)disable:(QCOpenGLContext *)context;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end