// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tiles NPR Hybrid"
{
	Properties
	{
		_TileTexture("Tile Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Float) = 0
		_NormalStrength("Normal Strength", Float) = 0
		_CamDepthFadeLength("CamDepthFadeLength", Float) = 0
		_CamDepthFadeOffset("CamDepthFadeOffset", Float) = 0
		_LightGradientIntensity("Light Gradient Intensity", Float) = 0
		_LightGradientOffset("Light Gradient Offset", Float) = 0
		_LightGradientScale("Light Gradient Scale", Float) = 0
		_PosterizeSteps("PosterizeSteps", Int) = 0
		_GradientKey01("GradientKey01", Color) = (0,0,0,0)
		_GradientKey02("GradientKey02", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
			float eyeDepth;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _TileTexture;
		uniform float _NormalStrength;
		uniform int _PosterizeSteps;
		uniform float _CamDepthFadeLength;
		uniform float _CamDepthFadeOffset;
		uniform float4 _GradientKey01;
		uniform float4 _GradientKey02;
		uniform float _LightGradientScale;
		uniform float _LightGradientOffset;
		uniform float _LightGradientIntensity;
		uniform float _Smoothness;


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			SurfaceOutputStandard s53 = (SurfaceOutputStandard ) 0;
			Gradient gradient18 = NewGradient( 0, 2, 2, float4( 0.4901961, 0.4035403, 0.3269608, 0 ), float4( 0.8155037, 0.9245283, 0.9187769, 0.2970626 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float4 tex2DNode2 = tex2D( _TileTexture, i.uv_texcoord );
			float4 temp_cast_0 = (tex2DNode2.r).xxxx;
			float4 blendOpSrc19 = SampleGradient( gradient18, tex2DNode2.r );
			float4 blendOpDest19 = temp_cast_0;
			float4 Albedo45 = ( saturate( (( blendOpDest19 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest19 ) * ( 1.0 - blendOpSrc19 ) ) : ( 2.0 * blendOpDest19 * blendOpSrc19 ) ) ));
			float4 color58 = IsGammaSpace() ? float4(0.1132075,0.1132075,0.1132075,0) : float4(0.01219615,0.01219615,0.01219615,0);
			Gradient gradient21 = NewGradient( 1, 2, 2, float4( 0, 0, 0, 0.4735332 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float4 LightAttenuationGradient23 = SampleGradient( gradient21, ase_lightAtten );
			float4 lerpResult60 = lerp( Albedo45 , color58 , LightAttenuationGradient23);
			s53.Albedo = lerpResult60.rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			float3 temp_output_16_0_g1 = ( ase_worldPos * 100.0 );
			float3 crossY18_g1 = cross( ase_worldNormal , ddy( temp_output_16_0_g1 ) );
			float3 worldDerivativeX2_g1 = ddx( temp_output_16_0_g1 );
			float dotResult6_g1 = dot( crossY18_g1 , worldDerivativeX2_g1 );
			float crossYDotWorldDerivX34_g1 = abs( dotResult6_g1 );
			float temp_output_20_0_g1 = ( tex2DNode2.b * _NormalStrength );
			float3 crossX19_g1 = cross( ase_worldNormal , worldDerivativeX2_g1 );
			float3 break29_g1 = ( sign( crossYDotWorldDerivX34_g1 ) * ( ( ddx( temp_output_20_0_g1 ) * crossY18_g1 ) + ( ddy( temp_output_20_0_g1 ) * crossX19_g1 ) ) );
			float3 appendResult30_g1 = (float3(break29_g1.x , -break29_g1.y , break29_g1.z));
			float3 normalizeResult39_g1 = normalize( ( ( crossYDotWorldDerivX34_g1 * ase_worldNormal ) - appendResult30_g1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g1 = mul( ase_worldToTangent, normalizeResult39_g1);
			float3 Normals49 = worldToTangentDir42_g1;
			s53.Normal = WorldNormalVector( i , Normals49 );
			float div26=256.0/float(_PosterizeSteps);
			float4 posterize26 = ( floor( Albedo45 * div26 ) / div26 );
			float cameraDepthFade39 = (( i.eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
			float4 color37 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float4 lerpResult40 = lerp( _GradientKey01 , _GradientKey02 , saturate( (ase_worldPos.y*_LightGradientScale + _LightGradientOffset) ));
			float4 blendOpSrc44 = ( cameraDepthFade39 * color37 );
			float4 blendOpDest44 = ( LightAttenuationGradient23 * lerpResult40 * _LightGradientIntensity );
			float4 lerpBlendMode44 = lerp(blendOpDest44,	max( blendOpSrc44, blendOpDest44 ),0.2);
			float4 NPREmissive51 = ( posterize26 * lerpBlendMode44 );
			s53.Emission = NPREmissive51.rgb;
			s53.Metallic = 0.0;
			float Smoothness47 = ( ( 1.0 - tex2DNode2.g ) * _Smoothness );
			s53.Smoothness = Smoothness47;
			s53.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi53 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g53 = UnityGlossyEnvironmentSetup( s53.Smoothness, data.worldViewDir, s53.Normal, float3(0,0,0));
			gi53 = UnityGlobalIllumination( data, s53.Occlusion, s53.Normal, g53 );
			#endif

			float3 surfResult53 = LightingStandard ( s53, viewDir, gi53 ).rgb;
			surfResult53 += s53.Emission;

			#ifdef UNITY_PASS_FORWARDADD//53
			surfResult53 -= s53.Emission;
			#endif//53
			c.rgb = surfResult53;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
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
-1926;19;1920;1022;4253.769;1117.632;2.795872;True;False
Node;AmplifyShaderEditor.CommentaryNode;55;-2098,-658;Inherit;False;1410;745;PBR;14;11;2;18;17;19;45;15;14;7;13;4;12;49;47;PBR;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-1792,256;Inherit;False;802;275;Light Gradient;4;23;22;21;56;Light Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-2048,-304;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;54;-2098,606;Inherit;False;1682;870;NPR;22;28;29;30;31;35;36;32;34;33;39;37;38;41;40;25;42;24;43;26;44;27;51;NPR;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2048,1360;Inherit;False;Property;_LightGradientOffset;Light Gradient Offset;6;0;Create;True;0;0;False;0;False;0;-5.07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;18;-1712,-608;Inherit;False;0;2;2;0.4901961,0.4035403,0.3269608,0;0.8155037,0.9245283,0.9187769,0.2970626;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1840,-304;Inherit;True;Property;_TileTexture;Tile Texture;0;0;Create;True;0;0;False;0;False;-1;714974d831a7a8c468e7e2a80bf7466d;714974d831a7a8c468e7e2a80bf7466d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;56;-1744,384;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;30;-2048,1136;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GradientNode;21;-1744,304;Inherit;False;1;2;2;0,0,0,0.4735332;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2048,1280;Inherit;False;Property;_LightGradientScale;Light Gradient Scale;7;0;Create;True;0;0;False;0;False;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;31;-1792,1216;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;17;-1504,-608;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientSampleNode;22;-1536,304;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;19;-1152,-512;Inherit;True;Overlay;True;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1216,304;Inherit;False;LightAttenuationGradient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;35;-1616,1216;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;36;-1792,1040;Inherit;False;Property;_GradientKey02;GradientKey02;10;0;Create;True;0;0;False;0;False;0,0,0,0;0.7547169,0.3059068,0.2385187,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-1760,656;Inherit;False;Property;_CamDepthFadeLength;CamDepthFadeLength;3;0;Create;True;0;0;False;0;False;0;21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-1792,864;Inherit;False;Property;_GradientKey01;GradientKey01;9;0;Create;True;0;0;False;0;False;0,0,0,0;0.7264151,0.4905488,0.31181,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-1760,736;Inherit;False;Property;_CamDepthFadeOffset;CamDepthFadeOffset;4;0;Create;True;0;0;False;0;False;0;25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;39;-1488,704;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1440,1296;Inherit;False;Property;_LightGradientIntensity;Light Gradient Intensity;5;0;Create;True;0;0;False;0;False;0;16.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;-1440,912;Inherit;False;Constant;_Color0;Color 0;2;0;Create;True;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-912,-512;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;40;-1440,1168;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-1440,1088;Inherit;False;23;LightAttenuationGradient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1216,816;Inherit;False;45;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;25;-1216,880;Inherit;False;Property;_PosterizeSteps;PosterizeSteps;8;0;Create;True;0;0;False;0;False;0;-5;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1200,976;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1168,1168;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1728,-48;Inherit;False;Property;_NormalStrength;Normal Strength;2;0;Create;True;0;0;False;0;False;0;10.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;26;-992,1072;Inherit;False;1;2;1;COLOR;0,0,0,0;False;0;INT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;44;-1024,1168;Inherit;False;Lighten;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1504,-176;Inherit;False;Property;_Smoothness;Smoothness;1;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;7;-1504,-240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1504,-48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;4;-1376,-48;Inherit;False;Normal From Height;-1;;1;1942fe2c5f1a1f94881a33d532e4afeb;0;1;20;FLOAT;0;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-768,1168;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1344,-240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1216,-240;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-1120,-48;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-640,1168;Inherit;False;NPREmissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;58;-602.8975,-506.8544;Inherit;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;False;0;False;0.1132075,0.1132075,0.1132075,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;59;-602.8975,-330.8545;Inherit;False;23;LightAttenuationGradient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-602.8975,-586.8544;Inherit;False;45;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;60;-298.8975,-506.8544;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-384,-176;Inherit;False;49;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-384,-96;Inherit;False;51;NPREmissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-384,-16;Inherit;False;47;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;53;-144,-256;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-384,-256;Inherit;False;45;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;128,-256;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Tiles NPR Hybrid;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;1;11;0
WireConnection;31;0;30;2
WireConnection;31;1;29;0
WireConnection;31;2;28;0
WireConnection;17;0;18;0
WireConnection;17;1;2;1
WireConnection;22;0;21;0
WireConnection;22;1;56;0
WireConnection;19;0;17;0
WireConnection;19;1;2;1
WireConnection;23;0;22;0
WireConnection;35;0;31;0
WireConnection;39;0;32;0
WireConnection;39;1;33;0
WireConnection;45;0;19;0
WireConnection;40;0;34;0
WireConnection;40;1;36;0
WireConnection;40;2;35;0
WireConnection;42;0;39;0
WireConnection;42;1;37;0
WireConnection;43;0;41;0
WireConnection;43;1;40;0
WireConnection;43;2;38;0
WireConnection;26;1;24;0
WireConnection;26;0;25;0
WireConnection;44;0;42;0
WireConnection;44;1;43;0
WireConnection;7;0;2;2
WireConnection;14;0;2;3
WireConnection;14;1;15;0
WireConnection;4;20;14;0
WireConnection;27;0;26;0
WireConnection;27;1;44;0
WireConnection;12;0;7;0
WireConnection;12;1;13;0
WireConnection;47;0;12;0
WireConnection;49;0;4;40
WireConnection;51;0;27;0
WireConnection;60;0;57;0
WireConnection;60;1;58;0
WireConnection;60;2;59;0
WireConnection;53;0;60;0
WireConnection;53;1;50;0
WireConnection;53;2;52;0
WireConnection;53;4;48;0
WireConnection;0;13;53;0
ASEEND*/
//CHKSM=ED77A419B6BF62C945BF1CA2931F84ACB4276B0E