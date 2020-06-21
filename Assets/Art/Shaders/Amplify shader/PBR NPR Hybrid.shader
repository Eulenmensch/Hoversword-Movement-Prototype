// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PBR NPR Hybrid"
{
	Properties
	{
		_TopTexture1("Top Texture 1", 2D) = "white" {}
		_TexturesCom_BuildingsIndustrial0136_2_M("TexturesCom_BuildingsIndustrial0136_2_M", 2D) = "white" {}
		_CamDepthFadeLength("CamDepthFadeLength", Float) = 0
		_CamDepthFadeOffset("CamDepthFadeOffset", Float) = 0
		_LightGradientIntensity("Light Gradient Intensity", Float) = 0
		_GradientOffset("GradientOffset", Float) = 0
		_GradientScale("GradientScale", Float) = 0
		_PosterizeSteps("PosterizeSteps", Int) = 0
		_GradientKey01("GradientKey01", Color) = (0,0,0,0)
		_GradientKey02("GradientKey02", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#define ASE_TEXTURE_PARAMS(textureName) textureName

		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float eyeDepth;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _TexturesCom_BuildingsIndustrial0136_2_M;
		uniform float4 _TexturesCom_BuildingsIndustrial0136_2_M_ST;
		uniform sampler2D _ScreenSpaceShadowMask;
		uniform float _CamDepthFadeLength;
		uniform float _CamDepthFadeOffset;
		uniform float4 _GradientKey01;
		uniform float4 _GradientKey02;
		uniform float _GradientScale;
		uniform float _GradientOffset;
		uniform float _LightGradientIntensity;
		uniform int _PosterizeSteps;
		uniform sampler2D _TopTexture1;


		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1);
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1);
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


		inline float4 TriplanarSamplingSF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			zNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_TexturesCom_BuildingsIndustrial0136_2_M = i.uv_texcoord * _TexturesCom_BuildingsIndustrial0136_2_M_ST.xy + _TexturesCom_BuildingsIndustrial0136_2_M_ST.zw;
			float4 tex2DNode14 = tex2D( _TexturesCom_BuildingsIndustrial0136_2_M, uv_TexturesCom_BuildingsIndustrial0136_2_M );
			float4 color54 = IsGammaSpace() ? float4(0.1132075,0.1132075,0.1132075,0) : float4(0.01219615,0.01219615,0.01219615,0);
			Gradient gradient28 = NewGradient( 1, 2, 2, float4( 0, 0, 0, 0.4735332 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos22 = UnityObjectToClipPos( ase_vertex3Pos );
			float4 computeScreenPos24 = ComputeScreenPos( unityObjectToClipPos22 );
			float4 lerpResult50 = lerp( tex2DNode14 , color54 , SampleGradient( gradient28, tex2D( _ScreenSpaceShadowMask, ( computeScreenPos24 / (computeScreenPos24).w ).xy ).r ));
			o.Albedo = lerpResult50.rgb;
			float cameraDepthFade30 = (( i.eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
			float4 color32 = IsGammaSpace() ? float4(0.04018334,0.04787051,0.1981132,0) : float4(0.003110165,0.003747073,0.03251993,0);
			float3 ase_worldPos = i.worldPos;
			float clampResult62 = clamp( (ase_worldPos.y*_GradientScale + _GradientOffset) , 0.0 , 1.0 );
			float4 lerpResult60 = lerp( _GradientKey01 , _GradientKey02 , clampResult62);
			float4 blendOpSrc33 = ( cameraDepthFade30 * color32 );
			float4 blendOpDest33 = ( SampleGradient( gradient28, tex2D( _ScreenSpaceShadowMask, ( computeScreenPos24 / (computeScreenPos24).w ).xy ).r ) * lerpResult60 * _LightGradientIntensity );
			float4 lerpBlendMode33 = lerp(blendOpDest33,	max( blendOpSrc33, blendOpDest33 ),0.2);
			float div55=256.0/float(_PosterizeSteps);
			float4 posterize55 = ( floor( tex2DNode14 * div55 ) / div55 );
			o.Emission = ( lerpBlendMode33 * posterize55 ).rgb;
			o.Metallic = tex2DNode14.r;
			float2 temp_cast_6 = (0.1).xx;
			float2 uv_TexCoord12 = i.uv_texcoord * temp_cast_6;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar13 = TriplanarSamplingSF( _TopTexture1, ase_worldPos, ase_worldNormal, 1.0, uv_TexCoord12, 1.0, 0 );
			o.Smoothness = triplanar13.x;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.z = customInputData.eyeDepth;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.eyeDepth = IN.customPack1.z;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
-1920;6;1920;1023;2138.21;59.36354;1;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;21;-2327.724,124.5435;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;22;-2158.723,124.5435;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;29;-1933.723,235.5434;Inherit;False;273;166;Only W!!!!!;1;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;24;-1964.723,124.5435;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;25;-1883.723,285.5433;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1462.133,531.3513;Inherit;False;Property;_GradientScale;GradientScale;7;0;Create;True;0;0;False;0;False;0;10.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;38;-1400.43,393.0953;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;52;-1435.744,598.9799;Inherit;False;Property;_GradientOffset;GradientOffset;6;0;Create;True;0;0;False;0;False;0;1.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;26;-1628.905,166.0785;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;45;-1173.481,391.1684;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;28;-1378.515,112.8196;Inherit;False;1;2;2;0,0,0,0.4735332;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.ColorNode;58;-1392.236,689.6553;Inherit;False;Property;_GradientKey01;GradientKey01;9;0;Create;True;0;0;False;0;False;0,0,0,0;0.8117647,0.6973845,0.6218117,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;59;-1387.036,887.2553;Inherit;False;Property;_GradientKey02;GradientKey02;10;0;Create;True;0;0;False;0;False;0,0,0,0;0.83,0.7143403,0.55942,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;-1499.576,197.7879;Inherit;True;Global;_ScreenSpaceShadowMask;_ScreenSpaceShadowMask;3;0;Create;True;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-1147.152,-175.758;Inherit;False;Property;_CamDepthFadeLength;CamDepthFadeLength;2;0;Create;True;0;0;False;0;False;0;120;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1144.152,-95.758;Inherit;False;Property;_CamDepthFadeOffset;CamDepthFadeOffset;4;0;Create;True;0;0;False;0;False;0;120.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;62;-1038.21,508.6365;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;27;-1181.466,178.7951;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;32;-887.1691,-50.4659;Inherit;False;Constant;_Color0;Color 0;2;0;Create;True;0;0;False;0;False;0.04018334,0.04787051,0.1981132,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;-941.6141,565.8528;Inherit;False;Property;_LightGradientIntensity;Light Gradient Intensity;5;0;Create;True;0;0;False;0;False;0;4.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;30;-901.9506,-195.5947;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;-920.3358,325.3552;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-550.7559,679.7314;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-523.689,239.3002;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-543.16,-155.2812;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;56;-451.3655,358.3503;Inherit;False;Property;_PosterizeSteps;PosterizeSteps;8;0;Create;True;0;0;False;0;False;0;-126;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;14;-610.8683,-372.7058;Inherit;True;Property;_TexturesCom_BuildingsIndustrial0136_2_M;TexturesCom_BuildingsIndustrial0136_2_M;1;0;Create;True;0;0;False;0;False;-1;3a450013f1d3f234da4217a9d03b2a6e;3a450013f1d3f234da4217a9d03b2a6e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;54;-525.3024,-21.01379;Inherit;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;False;0;False;0.1132075,0.1132075,0.1132075,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosterizeNode;55;-264.3746,272.6663;Inherit;False;1;2;1;COLOR;0,0,0,0;False;0;INT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;33;-171.1215,120.5404;Inherit;False;Lighten;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-510.555,506.0803;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;51.63452,162.3503;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;50;-49.68987,-2.744319;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TriplanarNode;13;-244.4817,400.4478;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;0;Assets/Art/Textures/TexturesCom_BuildingsIndustrial0136_2_M_smoothness.png;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;206.8458,91.58961;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;PBR NPR Hybrid;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;22;0;21;0
WireConnection;24;0;22;0
WireConnection;25;0;24;0
WireConnection;26;0;24;0
WireConnection;26;1;25;0
WireConnection;45;0;38;2
WireConnection;45;1;51;0
WireConnection;45;2;52;0
WireConnection;20;1;26;0
WireConnection;62;0;45;0
WireConnection;27;0;28;0
WireConnection;27;1;20;0
WireConnection;30;0;35;0
WireConnection;30;1;36;0
WireConnection;60;0;58;0
WireConnection;60;1;59;0
WireConnection;60;2;62;0
WireConnection;43;0;27;0
WireConnection;43;1;60;0
WireConnection;43;2;44;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;55;1;14;0
WireConnection;55;0;56;0
WireConnection;33;0;31;0
WireConnection;33;1;43;0
WireConnection;12;0;11;0
WireConnection;57;0;33;0
WireConnection;57;1;55;0
WireConnection;50;0;14;0
WireConnection;50;1;54;0
WireConnection;50;2;27;0
WireConnection;13;3;12;0
WireConnection;0;0;50;0
WireConnection;0;2;57;0
WireConnection;0;3;14;1
WireConnection;0;4;13;0
ASEEND*/
//CHKSM=B3468A122A938D35A0709B3324ED68989229D6E7