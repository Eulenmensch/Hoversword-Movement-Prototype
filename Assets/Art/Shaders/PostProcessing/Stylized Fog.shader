// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Stylized Fog"
{
	Properties
	{
		_DepthDivisor("Depth Divisor", Float) = 0
		_LerpAlpha("Lerp Alpha", Float) = 0
		_FogColor("Fog Color", Color) = (0.8113208,0.6988862,0.5549128,0)
		_FogColor1("Fog Color", Color) = (0,0.2602677,1,0)
		_MaxFogIntensity("Max Fog Intensity", Float) = 0
		_Scale("Scale", Float) = 0
		_Offset("Offset", Float) = 0

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
			uniform float4 _FogColor1;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _Scale;
			uniform float _Offset;
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
				float clampResult247 = clamp( ( (eyeDepth231*_Scale + _Offset) / _DepthDivisor ) , 0.0 , _MaxFogIntensity );
				float4 lerpResult251 = lerp( _FogColor , _FogColor1 , clampResult247);
				float2 uv0243 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 blendOpSrc256 = ( lerpResult251 * clampResult247 );
				float4 blendOpDest256 = tex2D( _MainTex, uv0243 );
				float4 lerpBlendMode256 = lerp(blendOpDest256,max( blendOpSrc256, blendOpDest256 ),saturate( _LerpAlpha ));
				

				float4 color = ( saturate( lerpBlendMode256 ));
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18100
1371;44;1189;985;1910.985;871.5581;1.369572;True;False
Node;AmplifyShaderEditor.RangedFloatNode;255;-1878.206,-62.67724;Inherit;False;Property;_Offset;Offset;6;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;254;-1882.381,-170.1739;Inherit;False;Property;_Scale;Scale;5;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;231;-1808.365,-325.3042;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;253;-1469.092,-147.2134;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;233;-1586.823,21.15338;Inherit;False;Property;_DepthDivisor;Depth Divisor;0;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;232;-1172.113,-76.11227;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-1274.954,50.03901;Inherit;False;Property;_MaxFogIntensity;Max Fog Intensity;4;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;247;-996.6289,-54.94569;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;250;-1387.987,-398.9749;Inherit;False;Property;_FogColor1;Fog Color;3;0;Create;True;0;0;False;0;False;0,0.2602677,1,0;0.8113208,0.6988862,0.5549128,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;235;-1390.704,-578.9223;Inherit;False;Property;_FogColor;Fog Color;2;0;Create;True;0;0;False;0;False;0.8113208,0.6988862,0.5549128,0;0.8113208,0.6988862,0.5549128,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;241;-1690.43,178.9326;Inherit;True;0;0;_MainTex;Pass;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;243;-1689.059,403.8111;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;251;-696.0249,-221.6536;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;245;-1021.281,290.0008;Inherit;False;Property;_LerpAlpha;Lerp Alpha;1;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-516.214,-162.5578;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;246;-862.2203,294.1145;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;242;-1318.832,176.1903;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;256;-293.9026,-7.994816;Inherit;False;Lighten;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;244;-458.9093,-403.5507;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;252;-996.6098,-190.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;222;-16.34492,-17.62061;Float;False;True;-1;2;ASEMaterialInspector;0;2;Stylized Fog;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;1;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;253;0;231;0
WireConnection;253;1;254;0
WireConnection;253;2;255;0
WireConnection;232;0;253;0
WireConnection;232;1;233;0
WireConnection;247;0;232;0
WireConnection;247;2;248;0
WireConnection;251;0;235;0
WireConnection;251;1;250;0
WireConnection;251;2;247;0
WireConnection;234;0;251;0
WireConnection;234;1;247;0
WireConnection;246;0;245;0
WireConnection;242;0;241;0
WireConnection;242;1;243;0
WireConnection;256;0;234;0
WireConnection;256;1;242;0
WireConnection;256;2;246;0
WireConnection;222;0;256;0
ASEEND*/
//CHKSM=003099EC1601AA4A40EF1C7368D6AF4A57324D65