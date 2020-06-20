// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Plasma_Test"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Texture0("Texture 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		[HDR]_GlowColor("GlowColor", Color) = (2.996078,0,0.5176471,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _GlowColor;
		uniform sampler2D _TextureSample1;
		uniform float4 _TextureSample1_ST;
		uniform sampler2D _Texture0;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color67 = IsGammaSpace() ? float4(1,0,0.3137255,0) : float4(1,0,0.08021983,0);
			float4 temp_cast_0 = (0.1509341).xxxx;
			float2 uv_TextureSample1 = i.uv_texcoord * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
			float4 appendResult27 = (float4(0.0 , -1.0 , 0.0 , 0.0));
			float2 uv_TexCoord24 = i.uv_texcoord * float2( 1.5,1 );
			float2 panner29 = ( 1.0 * _Time.y * appendResult27.xy + ( -1.0 * uv_TexCoord24 ));
			float4 appendResult34 = (float4(0.0 , 0.5 , 0.0 , 0.0));
			float2 panner35 = ( 1.0 * _Time.y * appendResult34.xy + ( 1.0 * uv_TexCoord24 ));
			float4 temp_output_65_0 = step( temp_cast_0 , ( tex2D( _TextureSample1, uv_TextureSample1 ) * ( tex2D( _Texture0, panner29 ).r * tex2D( _Texture0, panner35 ).r ) ) );
			float4 color70 = IsGammaSpace() ? float4(0,0.8527436,1,0) : float4(0,0.6971172,1,0);
			float4 temp_cast_3 = (0.1509341).xxxx;
			o.Emission = ( _GlowColor * ( ( color67 * ( 1.0 - temp_output_65_0 ) ) + ( color70 * temp_output_65_0 ) ) ).rgb;
			o.Alpha = 1;
			float4 temp_cast_5 = (0.05).xxxx;
			clip( step( temp_cast_5 , ( tex2D( _TextureSample1, uv_TextureSample1 ) * ( tex2D( _Texture0, panner29 ).r * tex2D( _Texture0, panner35 ).r ) ) ).r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
138;172;1443;802;3136.165;1007.227;3.789443;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;-1873.418,642.0258;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1.5,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-1846.938,1030.56;Inherit;False;Constant;_NoiseSpeed2;Noise Speed 2;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1846.795,935.0528;Inherit;False;Constant;_NoiseScale2;Noise Scale 2;4;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1855.119,433.1107;Inherit;False;Constant;_NoiseSpeed01;Noise Speed01;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1852.971,526.1561;Inherit;False;Constant;_NoiseScale1;Noise Scale 1;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1576.566,840.8506;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-1576.566,951.8506;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-1578.671,349.1834;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1583.119,512.1107;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;41;-1345.709,529.1855;Inherit;True;Property;_Texture0;Texture 0;3;0;Create;True;0;0;False;0;False;959ac56afcbab1f4983f84daf4ef9f08;959ac56afcbab1f4983f84daf4ef9f08;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;29;-1371.386,341.5835;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;35;-1368.833,847.3234;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;36;-1028.221,634.7916;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-1033.774,419.0517;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-667.6935,567.2704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;49;-736.4266,227.1926;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;False;-1;d9b938bec7a4c5e45a3c1adce6c3ded0;d9b938bec7a4c5e45a3c1adce6c3ded0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-356.0637,393.7732;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-168.201,273.5751;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;False;0;False;0.1509341;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;62;38.45728,398.915;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;65;192.1752,280.6182;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;67;366.0084,-16.67248;Inherit;False;Constant;_Color0;Color 0;5;0;Create;True;0;0;False;0;False;1,0,0.3137255,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;61;337.6475,169.0804;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;70;381.9032,253.0579;Inherit;False;Constant;_Color1;Color 1;5;0;Create;True;0;0;False;0;False;0,0.8527436,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;606.1368,413.7633;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;607.366,79.57436;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;72;858.0063,-26.70952;Inherit;False;Property;_GlowColor;GlowColor;5;1;[HDR];Create;True;0;0;False;0;False;2.996078,0,0.5176471,0;11.98431,0,2.070588,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;63;-192.285,495.8684;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;False;0.05;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;22;-2182.578,-663.5164;Inherit;False;1754.09;502.1994;;9;14;13;7;12;3;10;19;16;20;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;796.8985,208.8708;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1191.25,-298.1193;Inherit;False;Constant;_Booster;Booster;3;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;12;-1613.586,-612.6477;Inherit;False;Property;_Tiling;Tiling;2;0;Create;True;0;0;False;0;False;5,5;5,5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StepOpNode;66;194.1075,564.5934;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-885.3951,-417.2352;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1411.806,-605.6862;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;21;-390.4995,-349.3429;Inherit;True;20;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;1117.744,189.2726;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;7;-1708.8,-427.7361;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;13;-1948.909,-415.317;Inherit;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2132.578,-420.4561;Inherit;True;Property;_Speed;Speed;1;0;Create;True;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;10;-1170.55,-613.5165;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-652.4886,-427.0812;Inherit;True;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1395.008,174.2196;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Plasma_Test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;33;0;31;0
WireConnection;33;1;24;0
WireConnection;34;1;32;0
WireConnection;27;1;26;0
WireConnection;28;0;25;0
WireConnection;28;1;24;0
WireConnection;29;0;28;0
WireConnection;29;2;27;0
WireConnection;35;0;33;0
WireConnection;35;2;34;0
WireConnection;36;0;41;0
WireConnection;36;1;35;0
WireConnection;23;0;41;0
WireConnection;23;1;29;0
WireConnection;37;0;23;1
WireConnection;37;1;36;1
WireConnection;46;0;49;0
WireConnection;46;1;37;0
WireConnection;62;0;46;0
WireConnection;65;0;59;0
WireConnection;65;1;62;0
WireConnection;61;0;65;0
WireConnection;71;0;70;0
WireConnection;71;1;65;0
WireConnection;68;0;67;0
WireConnection;68;1;61;0
WireConnection;69;0;68;0
WireConnection;69;1;71;0
WireConnection;66;0;63;0
WireConnection;66;1;62;0
WireConnection;16;0;10;0
WireConnection;16;1;19;0
WireConnection;3;0;12;0
WireConnection;3;1;7;0
WireConnection;73;0;72;0
WireConnection;73;1;69;0
WireConnection;7;1;13;0
WireConnection;13;0;14;0
WireConnection;10;0;3;0
WireConnection;20;0;16;0
WireConnection;0;2;73;0
WireConnection;0;10;66;0
ASEEND*/
//CHKSM=3A2FD73B25FEAE6D5B2B8BBE1695D5642DEC0691