#import <OpenGL/CGLMacro.h>
#import "KinemeGLLogicOpPatch.h"

static const GLint modes[16] = 
{
	GL_CLEAR,
	GL_SET,
	GL_COPY,
	GL_COPY_INVERTED,
	GL_NOOP,
	GL_INVERT,
	GL_AND,
	GL_NAND,
	GL_OR,
	GL_NOR,
	GL_XOR,
	GL_EQUIV,
	GL_AND_REVERSE,
	GL_AND_INVERTED,
	GL_OR_REVERSE,
	GL_OR_INVERTED
};

@implementation KinemeGLLogicOpPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return YES;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	self=[super initWithIdentifier:fp8];

	if(self)
	{
		[inputMode setMaxIndexValue:15];
		[inputMode setIndexValue:2];
		[[self userInfo] setObject:@"Kineme GL Logic Op" forKey:@"name"];
	}

	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	GLint oldLogicOp;
	GLboolean isEnabled;
	
	glGetIntegerv(GL_LOGIC_OP_MODE,&oldLogicOp);
	isEnabled = glIsEnabled(GL_COLOR_LOGIC_OP);
	if(!isEnabled)
		glEnable(GL_COLOR_LOGIC_OP);
	
	glLogicOp(modes[ [inputMode indexValue] ]);
	
	[self executeSubpatches:time arguments:arguments];
	
	if(!isEnabled)
		glDisable(GL_COLOR_LOGIC_OP);
	glLogicOp(oldLogicOp);
	

	return YES;
}

@end
