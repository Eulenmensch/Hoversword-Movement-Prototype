// Upgrade NOTE: upgraded instancing buffer 'BlendTwoSides' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BlendTwoSides"
{
	Properties
	{
		_SppedMainTexUVNoiseUV("Spped Main Tex U/V + Noise U/V", Vector) = (0,0,0,0)
		_MainTexture("Main Texture", 2D) = "white" {}
		[HDR]_Color0("Color 0", Color) = (0,1.445026,2,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTexture;

		UNITY_INSTANCING_BUFFER_START(BlendTwoSides)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color0)
#define _Color0_arr BlendTwoSides
			UNITY_DEFINE_INSTANCED_PROP(float4, _SppedMainTexUVNoiseUV)
#define _SppedMainTexUVNoiseUV_arr BlendTwoSides
		UNITY_INSTANCING_BUFFER_END(BlendTwoSides)

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 _Color0_Instance = UNITY_ACCESS_INSTANCED_PROP(_Color0_arr, _Color0);
			float4 _SppedMainTexUVNoiseUV_Instance = UNITY_ACCESS_INSTANCED_PROP(_SppedMainTexUVNoiseUV_arr, _SppedMainTexUVNoiseUV);
			float4 appendResult3 = (float4(_SppedMainTexUVNoiseUV_Instance.x , _SppedMainTexUVNoiseUV_Instance.y , 0.0 , 0.0));
			float4 tex2DNode19 = tex2D( _MainTexture, ( float4( i.uv_texcoord, 0.0 , 0.0 ) + ( appendResult3 * _Time.y ) ).xy );
			o.Emission = ( _Color0_Instance + tex2DNode19 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
-1805;311;1589;807;992.5025;371.3313;1.336602;True;True
Node;AmplifyShaderEditor.Vector4Node;2;-1275,172.5;Inherit;False;InstancedProperty;_SppedMainTexUVNoiseUV;Spped Main Tex U/V + Noise U/V;1;0;Create;True;0;0;False;0;False;0,0,0,0;0,-3,0,-1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;5;-887,244.5;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;3;-822,41.5;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-600,106.5;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-616,-84.5;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-332,-9.5;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;49;349.1217,-390.0917;Inherit;False;InstancedProperty;_Color0;Color 0;13;1;[HDR];Create;True;0;0;False;0;False;0,1.445026,2,0;0,1.445026,2,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-160,-256.5;Inherit;True;Property;_MainTexture;Main Texture;2;0;Create;True;0;0;False;0;False;-1;None;b691c033547bdc64f827b0971a18900d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;34;-633.5693,-544.1272;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SignOpNode;37;-215.1475,-490.8284;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;39;210.8525,-818.8284;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;20;91,154.5;Inherit;True;Property;_Noise;Noise;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;21;33.63098,481.2866;Inherit;False;Property;_UseCustomData;Use Custom Data;8;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;463.8525,-612.8284;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;35;-654.1475,-390.8284;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-602,351.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;42;207.8525,-677.8284;Float;False;Property;_Emission;Emission;11;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;36;-397.1475,-461.8284;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;46;98.30948,-61.86427;Inherit;True;Property;_Mask;Mask;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;29;-982.0286,-1165.229;Inherit;False;Property;_FrontFacesColor;Front Faces Color;7;0;Create;True;0;0;False;0;False;0.04125132,0.270584,0.9716981,0;0.04125132,0.270584,0.9716981,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-73,260.5;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-192.369,487.2866;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;43;198.8525,-595.8284;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-641,216.5;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;33;-171.5496,-792.5325;Inherit;False;Property;_BackFacesColor;Back Faces Color;6;0;Create;True;0;0;False;0;False;0.8784314,0.02745098,0.3727982,0;0.8784314,0.02745098,0.3727982,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;528.5298,22.54932;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-836,439.5;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1477.055,-767.8137;Inherit;False;Property;_Fresnel;Fresnel;9;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;24;-1189.983,-775.1046;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-468.9104,-813.228;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;631.1217,-317.0917;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;27;-1358.814,-994.0405;Inherit;False;Property;_FresnelColor;Fresnel Color;5;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-905.6931,-867.6895;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;32;-169.3714,-957.0067;Inherit;False;Property;_UseFresnel;UseFresnel;12;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;38;-70.14746,-523.8284;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-680.2214,-966.8098;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;25;-912.2284,-705.3936;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;9;-356,244.5;Inherit;False;True;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1368.044,-1130.541;Inherit;False;Property;_FresnelEmission;Fresnel Emission;10;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;775.8477,-236.8298;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;BlendTwoSides;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;2;1
WireConnection;3;1;2;2
WireConnection;6;0;3;0
WireConnection;6;1;5;2
WireConnection;11;0;10;0
WireConnection;11;1;6;0
WireConnection;19;1;11;0
WireConnection;37;0;36;0
WireConnection;39;0;32;0
WireConnection;39;1;33;0
WireConnection;39;2;38;0
WireConnection;20;1;13;0
WireConnection;21;1;22;0
WireConnection;40;1;42;0
WireConnection;40;2;43;0
WireConnection;40;3;43;4
WireConnection;40;4;19;0
WireConnection;7;0;5;2
WireConnection;7;1;4;0
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;13;0;9;0
WireConnection;13;1;7;0
WireConnection;47;0;46;0
WireConnection;47;1;20;0
WireConnection;47;2;21;0
WireConnection;4;2;2;3
WireConnection;4;3;2;4
WireConnection;24;3;45;0
WireConnection;31;0;30;0
WireConnection;31;1;26;0
WireConnection;50;0;49;0
WireConnection;50;1;19;0
WireConnection;26;0;44;0
WireConnection;26;1;27;0
WireConnection;26;2;24;0
WireConnection;32;1;29;0
WireConnection;32;0;31;0
WireConnection;38;0;37;0
WireConnection;30;0;29;0
WireConnection;30;1;25;0
WireConnection;25;0;24;0
WireConnection;9;0;8;0
WireConnection;0;2;50;0
ASEEND*/
//CHKSM=3EA0728DA75E5487E5D25BA0CC078B029ECA3916