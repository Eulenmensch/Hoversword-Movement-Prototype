// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( StylizedFogPPSRenderer ), PostProcessEvent.AfterStack, "StylizedFog", true )]
public sealed class StylizedFogPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "Depth Divisor" )]
	public FloatParameter _DepthDivisor = new FloatParameter { value = 0f };
	[Tooltip( "Lerp Alpha" )]
	public FloatParameter _LerpAlpha = new FloatParameter { value = 0f };
	[Tooltip( "Fog Color" )]
	public ColorParameter _FogColor = new ColorParameter { value = new Color(0.8113207f,0.6988862f,0.5549127f,0f) };
	[Tooltip( "Max Fog Intensity" )]
	public FloatParameter _MaxFogIntensity = new FloatParameter { value = 0f };
}

public sealed class StylizedFogPPSRenderer : PostProcessEffectRenderer<StylizedFogPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "Stylized Fog" ) );
		sheet.properties.SetFloat( "_DepthDivisor", settings._DepthDivisor );
		sheet.properties.SetFloat( "_LerpAlpha", settings._LerpAlpha );
		sheet.properties.SetColor( "_FogColor", settings._FogColor );
		sheet.properties.SetFloat( "_MaxFogIntensity", settings._MaxFogIntensity );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif