// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HeatDistortion"
{
	Properties
	{
		_rock_normal("rock_normal", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Range( 0 , 1)) = 0
		_RippleScale("RippleScale", Range( 0 , 20)) = 0
		_RippleSpeed("RippleSpeed", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Overlay"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float4 screenPos;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _rock_normal;
		uniform float _RippleScale;
		uniform float _RippleSpeed;
		uniform float _NormalStrength;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor1 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( float4( ( UnpackNormal( tex2D( _rock_normal, ( _RippleScale * (( ( _Time.y * _RippleSpeed ) + ase_grabScreenPosNorm )).xyzw ).xy ) ) * _NormalStrength ) , 0.0 ) + ase_grabScreenPosNorm ).xy);
			o.Emission = screenColor1.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
0;525;1214;484;2131.965;415.0241;2.238782;True;False
Node;AmplifyShaderEditor.TimeNode;31;-1377.111,-254.5611;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;41;-1452.6,-109.0998;Inherit;False;Property;_RippleSpeed;RippleSpeed;4;0;Create;True;0;0;False;0;False;0;0.6602736;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1177.725,-166.4521;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;11;-1291.368,91.61292;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-1040.332,-124.1532;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1026.99,-203.404;Inherit;False;Property;_RippleScale;RippleScale;3;0;Create;True;0;0;False;0;False;0;0.1675857;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;33;-922.3799,-128.121;Inherit;False;FLOAT4;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-751.9993,-182.7978;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;10;-606.3726,-211.9724;Inherit;True;Property;_rock_normal;rock_normal;1;0;Create;True;0;0;False;0;False;-1;f45c3bd09301cc64783afc31dfca026b;f45c3bd09301cc64783afc31dfca026b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-583.1652,-18.04887;Inherit;False;Property;_NormalStrength;Normal Strength;2;0;Create;True;0;0;False;0;False;0;0.007;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-267.3376,-78.64188;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-119.8756,-25.85842;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;1;20.30716,-31.12322;Inherit;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;43;256.1272,-69.85349;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;HeatDistortion;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;Overlay;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;38;0;31;2
WireConnection;38;1;41;0
WireConnection;35;0;38;0
WireConnection;35;1;11;0
WireConnection;33;0;35;0
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;10;1;34;0
WireConnection;28;0;10;0
WireConnection;28;1;29;0
WireConnection;13;0;28;0
WireConnection;13;1;11;0
WireConnection;1;0;13;0
WireConnection;43;2;1;0
ASEEND*/
//CHKSM=39C0DF1414222F93A6FB21BCF2FBB20F5B6A6F67