#import "GLToolsPrincipal.h"

#import "KinemeGLContextInfoPatch.h"

#import "KinemeGLPointPatch.h"
#import "KinemeGLPointStructurePatch.h"
#import "KinemeGLLinePatch.h"
#import "KinemeGLLineStructurePatch.h"
#import "KinemeGLTrianglePatch.h"
#import "KinemeGLTriangleStructurePatch.h"
#import "KinemeGLQuadPatch.h"
#import "KinemeGLQuadStructurePatch.h"
#import "KinemeGLSplinePatch.h"
#import "KinemeGLClearDepthPatch.h"
#import "KinemeGLGenerateMipMapPatch.h"
#import "KinemeGLCubeStructurePatch.h"

#import "KinemeGLStructureRendererPatch.h"

#import "KinemeGLPolygonModePatch.h"
#import "KinemeGLMultMatrixPatch.h"
#import "KinemeGLLoadMatrixPatch.h"
#import "KinemeGLScalePatch.h"
#import "KinemeGLBlendEquationPatch.h"
#import "KinemeGLShadeModelPatch.h"
#import "KinemeGLLightingBypassPatch.h"
#import "KinemeGLViewportPatch.h"
#import "KinemeGLFieldOfViewPatch.h"
#import "KinemeGLPolygonOffsetPatch.h"

#import "KinemeGLDepthBufferAlphaThresholdPatch.h"
#import "KinemeGLLogicOpPatch.h"
#import "KinemeGLOrthoPatch.h"
#import "KinemeGLFrustumPatch.h"
#import "KinemeGLStereoEnvironmentPatch.h"
#import "KinemeGLColorMaskPatch.h"
#import "KinemeGLScissorPatch.h"

#import "KinemeGLRenderInImageWithDepthPatch.h"

#import "KinemeGLLookAtPatch.h"
#import "KinemeGLReadPixelsPatch.h"
#import "KinemeGLGridPatch.h"
#import "KinemeGLGridRendererPatch.h"
#import "KinemeGLGridGeneratorPatch.h"
#import "KinemeGLGridEditorPatch.h"
#import "KinemeGLCameraPatch.h"
#import "KinemeGLInverseRotation.h"

#import "KinemeSuperGLSLGridPatch.h"
#import "KinemeGLTorusPatch.h"
#import "KinemeGLLineExpressionPatch.h"

#import "KinemeGLDepthSortEnvironmentPatch.h"
#import "KinemeGLDepthSortSpritePatch.h"

#import <objc/runtime.h>

@implementation KinemeGLToolsPlugin
+ (void)registerNodesWithManager:(QCNodeManager*)manager
{
	KIRegisterPatch(KinemeGLBlendEquationPatch);
	KIRegisterPatch(KinemeGLCameraPatch);
	KIRegisterPatch(KinemeGLClearDepthPatch);
	KIRegisterPatch(KinemeGLColorMaskPatch);
	KIRegisterPatch(KinemeGLContextInfoPatch);
	KIRegisterPatch(KinemeGLCubeStructurePatch);
	KIRegisterPatch(KinemeGLDepthBufferAlphaThresholdPatch);
	KIRegisterPatch(KinemeGLDepthSortEnvironmentPatch);
	KIRegisterPatch(KinemeGLDepthSortSpritePatch);
	KIRegisterPatch(KinemeGLFieldOfViewPatch);
	KIRegisterPatch(KinemeGLFrustumPatch);
	KIRegisterPatch(KinemeGLGenerateMipMapPatch);
	KIRegisterPatch(KinemeGLGridEditorPatch);
	KIRegisterPatch(KinemeGLGridGeneratorPatch);
	KIRegisterPatch(KinemeGLGridPatch);
	KIRegisterPatch(KinemeGLGridRendererPatch); 
	KIRegisterPatch(KinemeGLInverseRotation);
	KIRegisterPatch(KinemeGLLightingBypassPatch);
	KIRegisterPatch(KinemeGLLineExpressionPatch); 
	KIRegisterPatch(KinemeGLLinePatch);
	KIRegisterPatch(KinemeGLLineStructurePatch);
	KIRegisterPatch(KinemeGLLoadMatrixPatch);
	KIRegisterPatch(KinemeGLLogicOpPatch);
	KIRegisterPatch(KinemeGLLookAtPatch);
	KIRegisterPatch(KinemeGLMultMatrixPatch); 
	KIRegisterPatch(KinemeGLOrthoPatch);
	KIRegisterPatch(KinemeGLPointPatch);
	KIRegisterPatch(KinemeGLPointStructurePatch);
	KIRegisterPatch(KinemeGLPolygonModePatch);
	KIRegisterPatch(KinemeGLPolygonOffsetPatch);
	KIRegisterPatch(KinemeGLQuadPatch);
	KIRegisterPatch(KinemeGLQuadStructurePatch);
	KIRegisterPatch(KinemeGLReadPixelsPatch);
	KIRegisterPatch(KinemeGLRenderInImageWithDepthPatch);
	KIRegisterPatch(KinemeGLScalePatch); 
	KIRegisterPatch(KinemeGLScissorPatch);
	KIRegisterPatch(KinemeGLShadeModelPatch);
	KIRegisterPatch(KinemeGLSplinePatch);
	KIRegisterPatch(KinemeGLStereoEnvironmentPatch);
	KIRegisterPatch(KinemeGLStructureRendererPatch);
	KIRegisterPatch(KinemeGLTorusPatch);
	KIRegisterPatch(KinemeGLTrianglePatch);
	KIRegisterPatch(KinemeGLTriangleStructurePatch);
	KIRegisterPatch(KinemeGLViewportPatch);
	KIRegisterPatch(KinemeSuperGLSLGridPatch);
}
@end
