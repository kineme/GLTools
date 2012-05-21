#import "KinemeGLContextInfoPatch.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

@implementation KinemeGLContextInfoPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 0;
}
+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self = [super initWithIdentifier: fp8])
		[[self userInfo] setObject:@"Kineme GL Context Info" forKey:@"name"];
	return self;
}

- (void)enable:(QCOpenGLContext *)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	//CGLSetCurrentContext([context CGLContextObj]);

	GLint v;
	GLfloat pointTextureSizes[2];

	glGetIntegerv(GL_RED_BITS,&v);
	[outputBitsRed setIndexValue:v];
	glGetIntegerv(GL_GREEN_BITS,&v);
	[outputBitsGreen setIndexValue:v];
	glGetIntegerv(GL_BLUE_BITS,&v);
	[outputBitsBlue setIndexValue:v];
	glGetIntegerv(GL_ALPHA_BITS,&v);
	[outputBitsAlpha setIndexValue:v];

	glGetIntegerv(GL_ACCUM_RED_BITS,&v);
	[outputBitsAccumRed setIndexValue:v];
	glGetIntegerv(GL_ACCUM_GREEN_BITS,&v);
	[outputBitsAccumGreen setIndexValue:v];
	glGetIntegerv(GL_ACCUM_BLUE_BITS,&v);
	[outputBitsAccumBlue setIndexValue:v];
	glGetIntegerv(GL_ACCUM_ALPHA_BITS,&v);
	[outputBitsAccumAlpha setIndexValue:v];

	glGetIntegerv(GL_DEPTH_BITS,&v);
	[outputBitsDepth setIndexValue:v];

	glGetIntegerv(GL_STENCIL_BITS,&v);
	[outputBitsStencil setIndexValue:v];
	
	glGetFloatv(GL_ALIASED_POINT_SIZE_RANGE, pointTextureSizes);
	[outputMinPointTextureSize setDoubleValue: pointTextureSizes[0]];
	[outputMaxPointTextureSize setDoubleValue: pointTextureSizes[1]];

	NSMutableDictionary *glDict = [[NSMutableDictionary alloc] initWithCapacity: 24];
	
	char *param;
	NSString *p;
	NSArray *temp;

	param = (char*)glGetString(GL_VENDOR);
	p = [[NSString alloc] initWithCString: param encoding: NSASCIIStringEncoding];
	[glDict setObject: p forKey: @"vendor"];
	[p release];
	
	param = (char*)glGetString(GL_RENDERER);
	p = [[NSString alloc] initWithCString: param encoding: NSASCIIStringEncoding];
	[glDict setObject: p forKey: @"renderer"];
	[p release];
	
	param = (char*)glGetString(GL_VERSION);
	p = [[NSString alloc] initWithCString: param encoding: NSASCIIStringEncoding];
	[glDict setObject: p forKey: @"version"];
	[p release];

	param = (char*)glGetString(GL_SHADING_LANGUAGE_VERSION);
	p = [[NSString alloc] initWithCString: param encoding: NSASCIIStringEncoding];
	[glDict setObject: p forKey: @"GLSL version"];
	[p release];
	
	param = (char*)glGetString(GL_EXTENSIONS);
	p = [[NSString alloc] initWithCString: param encoding: NSASCIIStringEncoding];
	temp = [p componentsSeparatedByString: @" "];
	[glDict setObject: temp forKey: @"extensions"];
	[p release];
	
	{
		NSMutableDictionary *limits = [[NSMutableDictionary alloc] initWithCapacity: 8];
		NSMutableDictionary *lim;
		GLint val[2];
		
		lim = [[NSMutableDictionary alloc] initWithCapacity: 6];
		
		glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS_EXT,  val);
		[lim setObject: [NSNumber numberWithInt: val[0]] forKey: @"MAX_COLOR_ATTACHMENTS_EXT"];
		glGetIntegerv(GL_MAX_RENDERBUFFER_SIZE_EXT,  val);
		[lim setObject: [NSNumber numberWithInt: val[0]] forKey: @"MAX_RENDERBUFFER_SIZE_EXT"];
		glGetIntegerv(GL_MAX_VIEWPORT_DIMS,  val);
		[lim setObject: [NSNumber numberWithInt: val[0]] forKey: @"MAX_VIEWPORT_DIMS"];
		glGetIntegerv(GL_MAX_DRAW_BUFFERS_ARB,  val);
		[lim setObject: [NSNumber numberWithInt: val[0]] forKey: @"MAX_DRAWBUFFERS_ARB"];
		glGetIntegerv(GL_MIN_PBUFFER_VIEWPORT_DIMS_APPLE,  val);
		[lim setObject: [NSNumber numberWithInt: val[0]] forKey: @"MIN_PBUFFER_VIEWPORT_DIMS_APPLE"];
		glGetIntegerv(GL_SUBPIXEL_BITS,  val);
		[lim setObject: [NSNumber numberWithInt: val[0]] forKey: @"SUBPIXEL_BITS"];

		[limits setObject: lim forKey: @"framebuffer"];
		[lim release];
		
		[glDict setObject: limits forKey: @"limits"];
		[limits release];
	}
	
	QCStructure *info = [[QCStructure alloc] initWithDictionary: glDict];
	[glDict release];
	[outputRendererInfo setStructureValue: info];
	[info release];
}
@end
