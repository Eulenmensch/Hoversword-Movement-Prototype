// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Stylized Fog"
{
	Properties
	{
		_DepthDivisor("Depth Divisor", Float) = 0
		_LerpAlpha("Lerp Alpha", Float) = 0
		_FogColor("Fog Color", Color) = (0.8113208,0.6988862,0.5549128,0)
		_MaxFogIntensity("Max Fog Intensity", Float) = 0

	}

	SubShader
	{
		LOD 0

		Cull Off
		ZWrite On
		ZTest Always
		
		Pass
		{
			CGPROGRAM

			

			#pragma vertex Vert
			#pragma fragment Frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED

		
			struct ASEAttributesDefault
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				
			};

			struct ASEVaryingsDefault
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordStereo : TEXCOORD1;
			#if STEREO_INSTANCING_ENABLED
				uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
			#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float4 _FogColor;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _DepthDivisor;
			uniform float _MaxFogIntensity;
			uniform float _LerpAlpha;


			
			float2 TransformTriangleVertexToUV (float2 vertex)
			{
				float2 uv = (vertex + 1.0) * 0.5;
				return uv;
			}

			ASEVaryingsDefault Vert( ASEAttributesDefault v  )
			{
				ASEVaryingsDefault o;
				o.vertex = float4(v.vertex.xy, 0.0, 1.0);
				o.texcoord = TransformTriangleVertexToUV (v.vertex.xy);
#if UNITY_UV_STARTS_AT_TOP
				o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
#endif
				o.texcoordStereo = TransformStereoScreenSpaceTex (o.texcoord, 1.0);

				v.texcoord = o.texcoordStereo;
				float4 ase_ppsScreenPosVertexNorm = float4(o.texcoordStereo,0,1);

				

				return o;
			}

			float4 Frag (ASEVaryingsDefault i  ) : SV_Target
			{
				float4 ase_ppsScreenPosFragNorm = float4(i.texcoordStereo,0,1);

				float eyeDepth231 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_ppsScreenPosFragNorm.xy ));
				float clampResult247 = clamp( ( eyeDepth231 / _DepthDivisor ) , 0.0 , _MaxFogIntensity );
				float2 uv0243 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 lerpResult244 = lerp( ( _FogColor * clampResult247 ) , tex2D( _MainTex, uv0243 ) , saturate( _LerpAlpha ));
				

				float4 color = lerpResult244;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18100
-1920;0;1920;1029;2753.118;716.4672;1.37121;True;False
Node;AmplifyShaderEditor.ScreenDepthNode;231;-1479.264,-157.0136;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;233;-1475.151,-66.51377;Inherit;False;Property;_DepthDivisor;Depth Divisor;0;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;232;-1172.113,-76.11227;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-1274.954,50.03901;Inherit;False;Property;_MaxFogIntensity;Max Fog Intensity;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;241;-1690.43,178.9326;Inherit;True;0;0;_MainTex;Pass;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;243;-1689.059,403.8111;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;245;-904.7274,215.9554;Inherit;False;Property;_LerpAlpha;Lerp Alpha;1;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;235;-1410.704,-370.9223;Inherit;False;Property;_FogColor;Fog Color;2;0;Create;True;0;0;False;0;False;0.8113208,0.6988862,0.5549128,0;0.8113208,0.6988862,0.5549128,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;247;-985.6289,-45.94569;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;242;-1318.832,176.1903;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-800.5153,-135.0742;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;246;-734.6974,71.97845;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;244;-622.2582,-132.3318;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;222;-459.1938,-132.5017;Float;False;True;-1;2;ASEMaterialInspector;0;2;Stylized Fog;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;1;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;232;0;231;0
WireConnection;232;1;233;0
WireConnection;247;0;232;0
WireConnection;247;2;248;0
WireConnection;242;0;241;0
WireConnection;242;1;243;0
WireConnection;234;0;235;0
WireConnection;234;1;247;0
WireConnection;246;0;245;0
WireConnection;244;0;234;0
WireConnection;244;1;242;0
WireConnection;244;2;246;0
WireConnection;222;0;244;0
ASEEND*/
//CHKSM=E42DF82D10D9F053CF27B0091A497DD03DF3CF84