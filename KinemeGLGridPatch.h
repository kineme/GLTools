

typedef struct
{
	CGFloat x, y, z, r, g, b, a, u, v;
} KinemeVertex;

@interface KinemeGLGridPatch : QCPatch
{
	QCIndexPort		*inputHeight;
	QCIndexPort		*inputWidth;
	
	QCBooleanPort	*inputSelectionEnabled;
	QCIndexPort		*inputSelection;
	QCNumberPort	*inputX;
	QCNumberPort	*inputY;
	QCNumberPort	*inputZ;
	QCNumberPort	*inputU;
	QCNumberPort	*inputV;
	QCColorPort		*inputColor;
	
	QCBooleanPort	*inputCommitChanges;
	
	QCBooleanPort	*inputAutoIncrementOnCommit;
	QCBooleanPort	*inputResetGrid;
	
	QCStructurePort	*outputGrid;
	QCIndexPort		*outputSelection;
	
	unsigned int width, height, selected;
	BOOL oldSelectionValue;
	BOOL oldCommitValue;
	KinemeVertex *vertex;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end