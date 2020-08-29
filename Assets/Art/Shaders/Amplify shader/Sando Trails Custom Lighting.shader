// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SandoTrailsNPRLight"
{
	Properties
	{
		_CamDepthFadeLength("CamDepthFadeLength", Float) = 0
		_CamDepthFadeOffset("CamDepthFadeOffset", Float) = 0
		_LightGradientIntensity("Light Gradient Intensity", Float) = 0
		_LightGradientOffset("Light Gradient Offset", Float) = 0
		_LightGradientScale("Light Gradient Scale", Float) = 0
		_PosterizeSteps("PosterizeSteps", Int) = 0
		_GradientKey01("GradientKey01", Color) = (0,0,0,0)
		_GradientKey02("GradientKey02", Color) = (0,0,0,0)
		_HighColor("HighColor", Color) = (0,0,0,0)
		_LowColor("Low Color", Color) = (0,0,0,0)
		_SandNormal("SandNormal", 2D) = "bump" {}
		_TrailMap("TrailMap", 2D) = "white" {}
		_SandSpeckColor("SandSpeckColor", Color) = (0.7688679,0.9786758,1,0)
		_PlayerPosition("PlayerPosition", Vector) = (0,0,0,0)
		_TerrainHalfSizeCameraSize("Terrain Half Size/Camera Size", Float) = 0
		_SandSpeckCutoff("SandSpeckCutoff", Float) = 0
		_FresnelScale("Fresnel Scale", Float) = 0.78
		_FresnelPower("Fresnel Power", Float) = 6.34
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_TrailColor("TrailColor", Color) = (0,0,0,0)
		_SandSpeckScale("SandSpeckScale", Float) = 0
		_WaveFrequency("WaveFrequency", Float) = 0
		_WaveFrequencyNoise("WaveFrequencyNoise", Float) = 0
		_WaveNoiseScale("WaveNoiseScale", Float) = 0
		_WaveLengthNoise("WaveLengthNoise", Float) = 0
		_WaveAmplitude("WaveAmplitude", Float) = 1.2
		_GradientScale("GradientScale", Float) = 0.17
		_GradientOffset("GradientOffset", Float) = 0
		_InternalNoiseScale("InternalNoiseScale", Float) = 0.3
		_NormalScale("NormalScale", Float) = 0
		_NormalStrength("Normal Strength", Float) = 0
		_Smoothness("Smoothness", Float) = 0
		_Metalness("Metalness", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry-100" }
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
			float3 worldPos;
			float2 uv_texcoord;
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

		uniform float4 _LowColor;
		uniform float4 _HighColor;
		uniform float _GradientScale;
		uniform float _GradientOffset;
		uniform float _WaveFrequency;
		uniform float _WaveFrequencyNoise;
		uniform float _WaveNoiseScale;
		uniform float _WaveLengthNoise;
		uniform float _WaveAmplitude;
		uniform float _InternalNoiseScale;
		uniform float4 _TrailColor;
		uniform sampler2D _TrailMap;
		uniform float3 _PlayerPosition;
		uniform float _TerrainHalfSizeCameraSize;
		uniform float _SandSpeckCutoff;
		uniform float _SandSpeckScale;
		uniform float4 _SandSpeckColor;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform sampler2D _SandNormal;
		uniform float _NormalScale;
		uniform float _NormalStrength;
		uniform int _PosterizeSteps;
		uniform float _CamDepthFadeLength;
		uniform float _CamDepthFadeOffset;
		uniform float4 _GradientKey01;
		uniform float4 _GradientKey02;
		uniform float _LightGradientScale;
		uniform float _LightGradientOffset;
		uniform float _LightGradientIntensity;
		uniform float _Metalness;
		uniform float _Smoothness;


		float2 unity_gradientNoise_dir( float2 p )
		{
			p = p % 289;
			float x = (34 * p.x + 1) * p.x % 289 + p.y;
			x = (34 * x + 1) * x % 289;
			x = frac(x / 41) * 2 - 1;
			return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
		}


		float unity_gradientNoise( float2 p )
		{
			float2 ip = floor(p);
			float2 fp = frac(p);
			float d00 = dot(unity_gradientNoise_dir(ip), fp);
			float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
			float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
			float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
			fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
			return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
		}


		float Unity_GradientNoise_float54_g3( float2 UV , float Scale )
		{
			return unity_gradientNoise(UV * Scale) + 0.5;
		}


		float Unity_GradientNoise_float54_g4( float2 UV , float Scale )
		{
			return unity_gradientNoise(UV * Scale) + 0.5;
		}


		inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }

		inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }

		inline float valueNoise (float2 uv)
		{
			float2 i = floor(uv);
			float2 f = frac( uv );
			f = f* f * (3.0 - 2.0 * f);
			uv = abs( frac(uv) - 0.5);
			float2 c0 = i + float2( 0.0, 0.0 );
			float2 c1 = i + float2( 1.0, 0.0 );
			float2 c2 = i + float2( 0.0, 1.0 );
			float2 c3 = i + float2( 1.0, 1.0 );
			float r0 = noise_randomValue( c0 );
			float r1 = noise_randomValue( c1 );
			float r2 = noise_randomValue( c2 );
			float r3 = noise_randomValue( c3 );
			float bottomOfGrid = noise_interpolate( r0, r1, f.x );
			float topOfGrid = noise_interpolate( r2, r3, f.x );
			float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
			return t;
		}


		float SimpleNoise(float2 UV)
		{
			float t = 0.0;
			float freq = pow( 2.0, float( 0 ) );
			float amp = pow( 0.5, float( 3 - 0 ) );
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(1));
			amp = pow(0.5, float(3-1));
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(2));
			amp = pow(0.5, float(3-2));
			t += valueNoise( UV/freq )*amp;
			return t;
		}


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
			SurfaceOutputStandard s214 = (SurfaceOutputStandard ) 0;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult79 = (float2(_WaveFrequencyNoise , _WaveNoiseScale));
			float2 uv_TexCoord8 = i.uv_texcoord * appendResult79;
			float2 UV54_g3 = uv_TexCoord8;
			float Scale54_g3 = _WaveLengthNoise;
			float localUnity_GradientNoise_float54_g3 = Unity_GradientNoise_float54_g3( UV54_g3 , Scale54_g3 );
			float2 temp_cast_0 = (( ( ( 1.0 - abs( ( ase_worldPos.x * _WaveFrequency ) ) ) + ( localUnity_GradientNoise_float54_g3 * ( _WaveAmplitude / 100.0 ) ) ) % 2.53 )).xx;
			float2 UV54_g4 = temp_cast_0;
			float Scale54_g4 = _InternalNoiseScale;
			float localUnity_GradientNoise_float54_g4 = Unity_GradientNoise_float54_g4( UV54_g4 , Scale54_g4 );
			float Waves194 = ( (ase_worldPos.y*_GradientScale + _GradientOffset) * localUnity_GradientNoise_float54_g4 );
			float4 lerpResult107 = lerp( _LowColor , _HighColor , saturate( Waves194 ));
			float4 MainColor133 = lerpResult107;
			float2 temp_cast_1 = (50.0).xx;
			float2 temp_cast_2 = (0.5).xx;
			float4 tex2DNode128 = tex2D( _TrailMap, (( ( ( ( (_PlayerPosition).xz - temp_cast_1 ) / -1000.0 ) - temp_cast_2 ) + saturate( i.uv_texcoord ) )*_TerrainHalfSizeCameraSize + 0.0) );
			float4 appendResult129 = (float4(tex2DNode128.r , tex2DNode128.g , tex2DNode128.b , 0.0));
			float4 TrailMapping207 = appendResult129;
			float4 lerpResult135 = lerp( MainColor133 , _TrailColor , TrailMapping207);
			float4 FinalColor136 = lerpResult135;
			float simpleNoise164 = SimpleNoise( i.uv_texcoord*_SandSpeckScale );
			float temp_output_3_0_g8 = ( _SandSpeckCutoff - ( simpleNoise164 * ( 1.0 - Waves194 ) ) );
			float4 Specks197 = ( ( 1.0 - saturate( ( temp_output_3_0_g8 / fwidth( temp_output_3_0_g8 ) ) ) ) * _SandSpeckColor );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV102 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode102 = ( 0.0 + _FresnelScale * pow( max( 1.0 - fresnelNdotV102 , 0.0001 ), _FresnelPower ) );
			float4 Fresnel200 = ( fresnelNode102 * _FresnelColor );
			float4 Albedo256 = ( FinalColor136 + Specks197 + Fresnel200 );
			float4 color253 = IsGammaSpace() ? float4(0.1132075,0.1132075,0.1132075,0) : float4(0.01219615,0.01219615,0.01219615,0);
			Gradient gradient227 = NewGradient( 1, 2, 2, float4( 0, 0, 0, 0.4735332 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float4 LightAttenuationGradient230 = SampleGradient( gradient227, ase_lightAtten );
			float4 lerpResult254 = lerp( Albedo256 , color253 , LightAttenuationGradient230);
			s214.Albedo = lerpResult254.xyz;
			float2 temp_cast_6 = (_NormalScale).xx;
			float2 uv_TexCoord28 = i.uv_texcoord * temp_cast_6;
			float2 temp_output_2_0_g9 = uv_TexCoord28;
			float2 break6_g9 = temp_output_2_0_g9;
			float temp_output_25_0_g9 = ( pow( 0.5 , 3.0 ) * 0.1 );
			float2 appendResult8_g9 = (float2(( break6_g9.x + temp_output_25_0_g9 ) , break6_g9.y));
			float4 tex2DNode14_g9 = tex2D( _SandNormal, temp_output_2_0_g9 );
			float temp_output_4_0_g9 = _NormalStrength;
			float3 appendResult13_g9 = (float3(1.0 , 0.0 , ( ( tex2D( _SandNormal, appendResult8_g9 ).g - tex2DNode14_g9.g ) * temp_output_4_0_g9 )));
			float2 appendResult9_g9 = (float2(break6_g9.x , ( break6_g9.y + temp_output_25_0_g9 )));
			float3 appendResult16_g9 = (float3(0.0 , 1.0 , ( ( tex2D( _SandNormal, appendResult9_g9 ).g - tex2DNode14_g9.g ) * temp_output_4_0_g9 )));
			float3 normalizeResult22_g9 = normalize( cross( appendResult13_g9 , appendResult16_g9 ) );
			float3 Normals211 = normalizeResult22_g9;
			s214.Normal = WorldNormalVector( i , Normals211 );
			float div260=256.0/float(_PosterizeSteps);
			float4 posterize260 = ( floor( Albedo256 * div260 ) / div260 );
			float cameraDepthFade239 = (( i.eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
			float4 color242 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float4 lerpResult232 = lerp( _GradientKey01 , _GradientKey02 , saturate( (ase_worldPos.y*_LightGradientScale + _LightGradientOffset) ));
			float4 blendOpSrc243 = ( cameraDepthFade239 * color242 );
			float4 blendOpDest243 = ( LightAttenuationGradient230 * lerpResult232 * _LightGradientIntensity );
			float4 lerpBlendMode243 = lerp(blendOpDest243,	max( blendOpSrc243, blendOpDest243 ),0.2);
			s214.Emission = ( posterize260 * lerpBlendMode243 ).rgb;
			s214.Metallic = _Metalness;
			s214.Smoothness = _Smoothness;
			s214.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi214 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g214 = UnityGlossyEnvironmentSetup( s214.Smoothness, data.worldViewDir, s214.Normal, float3(0,0,0));
			gi214 = UnityGlobalIllumination( data, s214.Occlusion, s214.Normal, g214 );
			#endif

			float3 surfResult214 = LightingStandard ( s214, viewDir, gi214 ).rgb;
			surfResult214 += s214.Emission;

			#ifdef UNITY_PASS_FORWARDADD//214
			surfResult214 -= s214.Emission;
			#endif//214
			c.rgb = surfResult214;
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

	Dependency "BaseMapShader"="ASESampleShaders/SimpleTerrainBase"
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
1407;90;1189;991;1356.003;70.04819;2.034985;True;False
Node;AmplifyShaderEditor.CommentaryNode;100;-3549.475,-341.1635;Inherit;False;2178.117;789.3458;Waves;23;72;15;75;80;79;2;81;82;8;18;12;19;14;17;74;73;71;9;21;5;7;11;194;Waves;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-3474.475,142.8884;Inherit;False;Property;_WaveNoiseScale;WaveNoiseScale;43;0;Create;True;0;0;False;0;False;0;5.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-3499.476,66.88831;Inherit;False;Property;_WaveFrequencyNoise;WaveFrequencyNoise;42;0;Create;True;0;0;False;0;False;0;7.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-2984.137,-291.1635;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;81;-3048.476,-14.11172;Inherit;False;Property;_WaveFrequency;WaveFrequency;41;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;79;-3258.476,75.88834;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-3035.878,230.7366;Inherit;False;Property;_WaveLengthNoise;WaveLengthNoise;44;0;Create;True;0;0;False;0;False;0;31.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-2848.789,-109.9348;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-3084.24,68.12284;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-3003.198,332.1824;Inherit;False;Property;_WaveAmplitude;WaveAmplitude;45;0;Create;True;0;0;False;0;False;1.2;334.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;210;-3712.613,1299.133;Inherit;False;2096.995;630;Trail Mapping;17;178;176;183;188;180;177;186;174;172;187;193;175;179;128;127;129;207;Trail Mapping;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;18;-2779.908,1.495071;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-2803.159,220.4595;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;12;-2849.459,73.24863;Inherit;False;GradientNoise;-1;;3;73bcad20642e36b47bcbf1cdbeca1c3f;0;2;2;FLOAT2;0,0;False;3;FLOAT;120;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-2632.908,0.4950409;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;172;-3726.613,1541.133;Inherit;False;Property;_PlayerPosition;PlayerPosition;33;0;Create;True;0;0;False;0;False;0,0,0;0.2211583,-3.34205,-0.4128698;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2615.373,72.87003;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-2458.592,0.8010406;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-3502.613,1653.133;Inherit;False;Constant;_CameraSize;CameraSize;25;0;Create;True;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;174;-3486.613,1541.133;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-3310.613,1653.133;Inherit;False;Constant;_TerrainSize;TerrainSize;25;0;Create;True;0;0;False;0;False;-1000;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2378.794,94.0847;Inherit;False;Property;_InternalNoiseScale;InternalNoiseScale;48;0;Create;True;0;0;False;0;False;0.3;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;9;-2334.194,0.7178192;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2.53;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2343.102,-69.76283;Inherit;False;Property;_GradientOffset;GradientOffset;47;0;Create;True;0;0;False;0;False;0;1.28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2339.476,-172.1118;Inherit;False;Property;_GradientScale;GradientScale;46;0;Create;True;0;0;False;0;False;0.17;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;186;-3278.613,1541.133;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;5;-2123.894,-147.0733;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.17;False;2;FLOAT;0.16;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;175;-3134.613,1733.133;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;7;-2124.166,-14.6452;Inherit;False;GradientNoise;-1;;4;73bcad20642e36b47bcbf1cdbeca1c3f;0;2;2;FLOAT2;0,0;False;3;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;177;-3118.613,1541.133;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;-500;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-3134.613,1653.133;Inherit;False;Constant;_OffsetByHalf;Offset By Half;25;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;193;-2910.613,1733.133;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;183;-2910.613,1541.133;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1888.106,-45.14719;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-2910.613,1813.133;Inherit;False;Property;_TerrainHalfSizeCameraSize;Terrain Half Size/Camera Size;34;0;Create;True;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-1719.664,-37.05652;Inherit;False;Waves;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;198;-2795.196,572.5403;Inherit;False;1434.545;463.9413;Specks;12;84;92;164;95;91;165;167;169;98;196;170;197;Specks;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;205;-3531.452,-958.69;Inherit;False;928.8063;509.4033;Gradient Color;6;107;126;195;110;108;133;Gradient Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;176;-2730.399,1541.133;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-2709.542,866.1801;Inherit;False;Property;_SandSpeckScale;SandSpeckScale;40;0;Create;True;0;0;False;0;False;0;120000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;127;-2558.613,1349.133;Inherit;True;Property;_TrailMap;TrailMap;31;0;Create;True;0;0;False;0;False;None;fc184eb6607beb14699241c6ff2a7816;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;178;-2574.613,1541.133;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;84;-2745.196,665.1285;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;195;-3481.452,-565.2866;Inherit;False;194;Waves;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-2392.379,622.5403;Inherit;False;194;Waves;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;110;-3333.346,-738.2532;Inherit;False;Property;_HighColor;HighColor;28;0;Create;True;0;0;False;0;False;0,0,0,0;1,0.415016,0.1179245,0.9843137;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;98;-2194.292,648.3096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;126;-3269.265,-563.6396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;128;-2302.613,1525.133;Inherit;True;Property;_TextureSample0;Texture Sample 0;21;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;108;-3336.136,-908.69;Inherit;False;Property;_LowColor;Low Color;29;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;164;-2500.015,658.0577;Inherit;False;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;204;-3810.421,558.2791;Inherit;False;968.8518;588.307;Fresnel;8;102;106;105;200;103;104;202;203;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-2461.342,882.2797;Inherit;False;Property;_SandSpeckCutoff;SandSpeckCutoff;35;0;Create;True;0;0;False;0;False;0;0.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-2274.907,724.9262;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;129;-2000.125,1553.847;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;107;-3069.338,-785.0907;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;133;-2826.645,-789.7126;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-3747.047,970.063;Inherit;False;Property;_FresnelPower;Fresnel Power;37;0;Create;True;0;0;False;0;False;6.34;8.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;165;-2145.083,724.3404;Inherit;False;Step Antialiasing;-1;;8;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;1.48;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;209;-2482.885,-908.5834;Inherit;False;658;422;Final Color;5;208;135;132;134;136;Final Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;202;-3742.954,895.3511;Inherit;False;Property;_FresnelScale;Fresnel Scale;36;0;Create;True;0;0;False;0;False;0.78;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;103;-3760.421,608.2791;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;104;-3738.151,750.4206;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-1839.619,1549.775;Inherit;False;TrailMapping;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;169;-1962.287,729.0192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-2400.885,-858.5834;Inherit;False;133;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;132;-2432.885,-778.5834;Inherit;False;Property;_TrailColor;TrailColor;39;0;Create;True;0;0;False;0;False;0,0,0,0;0.8490566,0.399302,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;106;-3466.827,934.5862;Inherit;False;Property;_FresnelColor;FresnelColor;38;0;Create;True;0;0;False;0;False;0,0,0,0;0.509434,0.2257492,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;167;-2030.934,824.4816;Inherit;False;Property;_SandSpeckColor;SandSpeckColor;32;0;Create;True;0;0;False;0;False;0.7688679,0.9786758,1,0;0.2463061,0.4094244,0.4245279,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;102;-3523.653,715.3947;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.78;False;3;FLOAT;6.34;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-2416.885,-602.5835;Inherit;False;207;TrailMapping;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;135;-2192.885,-778.5834;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-1799.499,711.2061;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-3193.862,716.923;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;251;-2809.29,2068.972;Inherit;False;802;275;Light Gradient;4;230;229;227;228;Light Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightAttenuation;228;-2759.29,2182.972;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;233;-976,3136;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GradientNode;227;-2759.29,2118.972;Inherit;False;1;2;2;0,0,0,0.4735332;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.RangedFloatNode;235;-976,3376;Inherit;False;Property;_LightGradientOffset;Light Gradient Offset;22;0;Create;True;0;0;False;0;False;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-976,3296;Inherit;False;Property;_LightGradientScale;Light Gradient Scale;23;0;Create;True;0;0;False;0;False;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;-1584.652,729.0049;Inherit;False;Specks;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;213;-3826.667,2054.653;Inherit;False;914;486;Normals;6;66;28;68;32;67;211;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;258;-1799.292,-845.3769;Inherit;False;583.2917;326.0001;Albedo;5;137;199;201;56;256;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-2048.885,-778.5834;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-3065.569,715.5287;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-3776.666,2296.653;Inherit;False;Property;_NormalScale;NormalScale;49;0;Create;True;0;0;False;0;False;0;0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-1749.292,-795.3769;Inherit;False;136;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-1749.292,-715.3769;Inherit;False;197;Specks;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;229;-2551.29,2118.972;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;223;-693.145,3154.235;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-1749.292,-635.3768;Inherit;False;200;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;226;-663.6201,2749.282;Inherit;False;Property;_GradientKey01;GradientKey01;25;0;Create;True;0;0;False;0;False;0,0,0,0;1,0.7771344,0.3632075,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;240;-65.48413,2626.568;Inherit;False;Property;_CamDepthFadeLength;CamDepthFadeLength;19;0;Create;True;0;0;False;0;False;0;20.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;224;-663.6771,2915.34;Inherit;False;Property;_GradientKey02;GradientKey02;26;0;Create;True;0;0;False;0;False;0,0,0,0;1,0.859621,0.3066038,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;230;-2231.29,2118.972;Inherit;False;LightAttenuationGradient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;67;-3648.667,2104.653;Inherit;True;Property;_SandNormal;SandNormal;30;0;Create;True;0;0;False;0;False;None;dd1ad706663683546b665fd5b0286bbd;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-3616.667,2296.653;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;12.73,15.73;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-3616.667,2424.653;Inherit;False;Property;_NormalStrength;Normal Strength;50;0;Create;True;0;0;False;0;False;0;4.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-1568,-736;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-62.48413,2706.568;Inherit;False;Property;_CamDepthFadeOffset;CamDepthFadeOffset;20;0;Create;True;0;0;False;0;False;0;25.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;236;-506.7952,3155.836;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;239;209.6368,2625.144;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;237;-474.5841,3324.902;Inherit;False;Property;_LightGradientIntensity;Light Gradient Intensity;21;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;242;196.7999,2781.781;Inherit;False;Constant;_Color0;Color 0;2;0;Create;True;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;231;-395.3722,2910.898;Inherit;False;230;LightAttenuationGradient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-1440,-720;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;232;-308.1501,3121.15;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;66;-3360.667,2200.653;Inherit;False;NormalCreate;51;;9;e12f7ae19d416b942820e3932b56220f;0;4;1;SAMPLER2D;;False;2;FLOAT2;0,0;False;3;FLOAT;0.5;False;4;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;-848,1168;Inherit;False;256;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;-960,160;Inherit;False;256;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;-109.9687,3174.623;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;-960,416;Inherit;False;230;LightAttenuationGradient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;462.5561,2766.725;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;211;-3136.667,2232.653;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;253;-960,240;Inherit;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;False;0;False;0.1132075,0.1132075,0.1132075,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;259;-848,1248;Inherit;False;Property;_PosterizeSteps;PosterizeSteps;24;0;Create;True;0;0;False;0;False;0;-5;0;1;INT;0
Node;AmplifyShaderEditor.BlendOpsNode;243;652.1024,3007.961;Inherit;False;Lighten;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;260;-656,1168;Inherit;False;1;2;1;COLOR;0,0,0,0;False;0;INT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1232,752;Inherit;False;Property;_Smoothness;Smoothness;53;0;Create;True;0;0;False;0;False;0;0.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;254;-656,240;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;212;-1232,592;Inherit;False;211;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1216,672;Inherit;False;Property;_Metalness;Metalness;54;0;Create;True;0;0;False;0;False;0;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-352,1120;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1;-480,512;Inherit;False;Four Splats First Pass Terrain;1;;10;37452fdfb732e1443b7e39720d05b708;0;6;59;FLOAT4;0,0,0,0;False;60;FLOAT4;0,0,0,0;False;61;FLOAT3;0,0,0;False;57;FLOAT;0;False;58;FLOAT;0;False;62;FLOAT;0;False;6;FLOAT4;0;FLOAT3;14;FLOAT;56;FLOAT;45;FLOAT;19;FLOAT3;17
Node;AmplifyShaderEditor.RangedFloatNode;248;-320.6133,3804.201;Inherit;False;Property;_SmoothnessMultiplier;SmoothnessMultiplier;27;0;Create;True;0;0;False;0;False;0.5;0.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;246;-688.6135,3612.201;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;250;63.3869,3612.201;Inherit;False;Smoothness;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;249;-64.61314,3612.201;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomStandardSurface;214;-128,512;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TriplanarNode;245;-480.6134,3612.201;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;0;Assets/Art/Textures/TexturesCom_BuildingsIndustrial0136_2_M_smoothness.png;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;264;-650.7831,824.2811;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-832.6135,3628.201;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;265;446.6707,821.746;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;742.1356,335.2002;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SandoTrailsNPRLight;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;-100;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;1;BaseMapShader=ASESampleShaders/SimpleTerrainBase;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;79;0;80;0
WireConnection;79;1;75;0
WireConnection;82;0;2;1
WireConnection;82;1;81;0
WireConnection;8;0;79;0
WireConnection;18;0;82;0
WireConnection;15;0;11;0
WireConnection;12;2;8;0
WireConnection;12;3;72;0
WireConnection;19;0;18;0
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;17;0;19;0
WireConnection;17;1;14;0
WireConnection;174;0;172;0
WireConnection;9;0;17;0
WireConnection;186;0;174;0
WireConnection;186;1;187;0
WireConnection;5;0;2;2
WireConnection;5;1;74;0
WireConnection;5;2;73;0
WireConnection;7;2;9;0
WireConnection;7;3;71;0
WireConnection;177;0;186;0
WireConnection;177;1;180;0
WireConnection;193;0;175;0
WireConnection;183;0;177;0
WireConnection;183;1;188;0
WireConnection;21;0;5;0
WireConnection;21;1;7;0
WireConnection;194;0;21;0
WireConnection;176;0;183;0
WireConnection;176;1;193;0
WireConnection;178;0;176;0
WireConnection;178;1;179;0
WireConnection;98;0;196;0
WireConnection;126;0;195;0
WireConnection;128;0;127;0
WireConnection;128;1;178;0
WireConnection;164;0;84;0
WireConnection;164;1;92;0
WireConnection;95;0;164;0
WireConnection;95;1;98;0
WireConnection;129;0;128;1
WireConnection;129;1;128;2
WireConnection;129;2;128;3
WireConnection;107;0;108;0
WireConnection;107;1;110;0
WireConnection;107;2;126;0
WireConnection;133;0;107;0
WireConnection;165;1;95;0
WireConnection;165;2;91;0
WireConnection;207;0;129;0
WireConnection;169;0;165;0
WireConnection;102;0;103;0
WireConnection;102;4;104;0
WireConnection;102;2;202;0
WireConnection;102;3;203;0
WireConnection;135;0;134;0
WireConnection;135;1;132;0
WireConnection;135;2;208;0
WireConnection;170;0;169;0
WireConnection;170;1;167;0
WireConnection;105;0;102;0
WireConnection;105;1;106;0
WireConnection;197;0;170;0
WireConnection;136;0;135;0
WireConnection;200;0;105;0
WireConnection;229;0;227;0
WireConnection;229;1;228;0
WireConnection;223;0;233;2
WireConnection;223;1;234;0
WireConnection;223;2;235;0
WireConnection;230;0;229;0
WireConnection;28;0;68;0
WireConnection;56;0;137;0
WireConnection;56;1;199;0
WireConnection;56;2;201;0
WireConnection;236;0;223;0
WireConnection;239;0;240;0
WireConnection;239;1;241;0
WireConnection;256;0;56;0
WireConnection;232;0;226;0
WireConnection;232;1;224;0
WireConnection;232;2;236;0
WireConnection;66;1;67;0
WireConnection;66;2;28;0
WireConnection;66;4;32;0
WireConnection;225;0;231;0
WireConnection;225;1;232;0
WireConnection;225;2;237;0
WireConnection;238;0;239;0
WireConnection;238;1;242;0
WireConnection;211;0;66;0
WireConnection;243;0;238;0
WireConnection;243;1;225;0
WireConnection;260;1;261;0
WireConnection;260;0;259;0
WireConnection;254;0;257;0
WireConnection;254;1;253;0
WireConnection;254;2;255;0
WireConnection;262;0;260;0
WireConnection;262;1;243;0
WireConnection;1;60;254;0
WireConnection;1;61;212;0
WireConnection;1;57;22;0
WireConnection;1;58;30;0
WireConnection;246;0;247;0
WireConnection;250;0;249;0
WireConnection;249;0;245;0
WireConnection;249;1;248;0
WireConnection;214;0;1;0
WireConnection;214;1;1;14
WireConnection;214;2;262;0
WireConnection;214;3;1;56
WireConnection;214;4;1;45
WireConnection;245;3;246;0
WireConnection;0;13;214;0
ASEEND*/
//CHKSM=6C4333DAB8C67BF713B3E420DF973FB3E797105A