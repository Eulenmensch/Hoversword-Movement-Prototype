// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "moving led lights"
{
	Properties
	{
		_ledpattern("led pattern", 2D) = "white" {}
		_Emission("Emission", Float) = 100
		_Speed("Speed", Float) = 0.2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		Blend One One , OneMinusDstColor One
		BlendOp Add
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _ledpattern;
		uniform float _Speed;
		uniform float _Emission;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (( _Time.x * _Speed )).xx;
			float2 panner5 = ( 1.0 * _Time.y * temp_cast_0 + i.uv_texcoord);
			o.Albedo = ( tex2D( _ledpattern, panner5 ) * _Emission ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
-990;166;985;1005;1660.88;422.9449;1.130717;True;False
Node;AmplifyShaderEditor.TimeNode;8;-1850.164,238.8364;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-1760.199,414.7556;Inherit;False;Property;_Speed;Speed;3;0;Create;True;0;0;False;0;False;0.2;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1586.199,206.7556;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1718.164,51.83643;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;5;-1345.164,79.83643;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-719.1636,263.8364;Inherit;False;Property;_Emission;Emission;2;0;Create;True;0;0;False;0;False;100;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-981.1636,41.83643;Inherit;True;Property;_ledpattern;led pattern;0;0;Create;True;0;0;False;0;False;-1;2dfe1239956d0fe48af0c03e0aed1eda;84e676d170ac9ff4c8b35accd759a20a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-529.1636,209.8364;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;12;-258,-4;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;moving led lights;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;5;4;False;-1;1;False;-1;1;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;8;1
WireConnection;9;1;10;0
WireConnection;5;0;6;0
WireConnection;5;2;9;0
WireConnection;1;1;5;0
WireConnection;3;0;1;0
WireConnection;3;1;4;0
WireConnection;12;0;3;0
ASEEND*/
//CHKSM=11BF7C7CC9B27EFE8E29F797834EA2097F7DB6F6