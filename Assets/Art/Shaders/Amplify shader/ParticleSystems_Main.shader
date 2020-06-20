// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ParticleSystems_Shader"
{
	Properties
	{
		_SpeedMainTexUVNoiseZW("Speed MainTex U/V + Noise Z/W", Vector) = (0,0,0,0)
		[Toggle(_USECUSTOMDATA_ON)] _UseCustomData("UseCustomData", Float) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("Main Tex", 2D) = "white" {}
		[Toggle(_USEFRESNEL_ON)] _UseFresnel("Use Fresnel?", Float) = 1
		_Mask("Mask", 2D) = "white" {}
		_FrontFaceColor("Front Face Color", Color) = (0,0.1910429,1,0)
		_FresnelColor("Fresnel Color", Color) = (1,1,1,0)
		_BackFaceColor("Back Face Color", Color) = (0,0.3149304,1,0)
		_Noise("Noise", 2D) = "white" {}
		_Fresnel("Fresnel", Float) = 1
		_FresnelEmission("Fresnel Emission", Float) = 1
		_Emission("Emission", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _tex4coord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _USEFRESNEL_ON
		#pragma shader_feature_local _USECUSTOMDATA_ON
		#pragma surface surf Unlit keepalpha noshadow 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float3 viewDir;
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float4 uv_tex4coord;
		};

		uniform float4 _BackFaceColor;
		uniform float4 _FrontFaceColor;
		uniform float _Fresnel;
		uniform float _FresnelEmission;
		uniform float4 _FresnelColor;
		uniform float _Emission;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _SpeedMainTexUVNoiseZW;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform sampler2D _Noise;
		uniform float4 _Noise_ST;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV32 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode32 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV32, _Fresnel ) );
			#ifdef _USEFRESNEL_ON
				float4 staticSwitch39 = ( ( _FrontFaceColor * ( 1.0 - fresnelNode32 ) ) + ( _FresnelEmission * _FresnelColor * fresnelNode32 ) );
			#else
				float4 staticSwitch39 = _FrontFaceColor;
			#endif
			float dotResult26 = dot( ase_worldNormal , i.viewDir );
			float4 lerpResult41 = lerp( _BackFaceColor , staticSwitch39 , (0.0 + (sign( dotResult26 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)));
			float2 uv0_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 appendResult3 = (float2(_SpeedMainTexUVNoiseZW.x , _SpeedMainTexUVNoiseZW.y));
			o.Emission = ( lerpResult41 * _Emission * i.vertexColor * tex2D( _MainTex, ( uv0_MainTex + ( appendResult3 * _Time.y ) ) ) ).rgb;
			o.Alpha = 1;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 uv0_Noise = i.uv_tex4coord;
			uv0_Noise.xy = i.uv_tex4coord.xy * _Noise_ST.xy + _Noise_ST.zw;
			float2 appendResult4 = (float2(_SpeedMainTexUVNoiseZW.z , _SpeedMainTexUVNoiseZW.w));
			#ifdef _USECUSTOMDATA_ON
				float staticSwitch16 = uv0_Noise.z;
			#else
				float staticSwitch16 = 1.0;
			#endif
			clip( ( tex2D( _Mask, uv_Mask ) * tex2D( _Noise, ( (uv0_Noise).xy + ( _Time.y * appendResult4 ) ) ) * staticSwitch16 * 1.0 ).r - _Cutoff );
		}

		ENDCG
	}
}
/*ASEBEGIN
Version=18100
202;247;1443;723;2256.287;1621.937;3.853491;True;True
Node;AmplifyShaderEditor.RangedFloatNode;34;-856.9816,-689.508;Inherit;False;Property;_Fresnel;Fresnel;10;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;32;-593.37,-777.6859;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;31;-215.8884,-754.4665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-569.8455,-979.16;Inherit;False;Property;_FresnelColor;Fresnel Color;7;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-553.6212,-1075.009;Inherit;False;Property;_FresnelEmission;Fresnel Emission;11;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;1;-775.0705,120.0997;Inherit;False;Property;_SpeedMainTexUVNoiseZW;Speed MainTex U/V + Noise Z/W;0;0;Create;True;0;0;False;0;False;0,0,0,0;1,0,-0.5,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;24;-133.7517,-479.7304;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;37;-224.8014,-1157.669;Inherit;False;Property;_FrontFaceColor;Front Face Color;6;0;Create;True;0;0;False;0;False;0,0.1910429,1,0;1,0,0.5509934,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;23;-162.6028,-633.9205;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-107.9911,125.9806;Inherit;False;0;21;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;5;-400.4317,144.3479;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;44.71138,-909.2678;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-205.9888,-906.6682;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;26;88.59826,-589.0386;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;3;-369.3112,23.47199;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-372.6108,299.3515;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-121.9911,-13.01944;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SignOpNode;27;262.3024,-591.9163;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;211.9704,-789.8221;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;191.0089,-158.0194;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;12;228.3076,158.7893;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-130.9911,312.9806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;15;474.7191,397.7717;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;39;407.9173,-986.0678;Inherit;False;Property;_UseFresnel;Use Fresnel?;4;0;Create;True;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;40;471.4787,-647.2128;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;482.2589,-34.76942;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;33;444.8844,-858.0231;Inherit;False;Property;_BackFaceColor;Back Face Color;8;0;Create;True;0;0;False;0;False;0,0.3149304,1,0;1,0,0.347187,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;13;475.0571,288.2891;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;21;706.7123,210.5829;Inherit;True;Property;_Noise;Noise;9;0;Create;True;0;0;False;0;False;-1;None;ef24162546191d14b9ef2ba36f17b48b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;950.2859,545.3663;Inherit;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;853.222,-915.0575;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;45;837.3765,-670.3361;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;771.1147,-351.6552;Inherit;True;Property;_MainTex;Main Tex;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;16;639.0189,482.4716;Inherit;False;Property;_UseCustomData;UseCustomData;1;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;20;705.7123,16.58293;Inherit;True;Property;_Mask;Mask;5;0;Create;True;0;0;False;0;False;-1;None;959ac56afcbab1f4983f84daf4ef9f08;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;865.4276,-771.3165;Inherit;False;Property;_Emission;Emission;12;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;1202.022,211.1413;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;1146.43,-773.5681;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1573.71,-35.35201;Float;False;True;-1;2;;0;0;Unlit;ParticleSystems_Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;3;34;0
WireConnection;31;0;32;0
WireConnection;29;0;37;0
WireConnection;29;1;31;0
WireConnection;30;0;36;0
WireConnection;30;1;35;0
WireConnection;30;2;32;0
WireConnection;26;0;23;0
WireConnection;26;1;24;0
WireConnection;3;0;1;1
WireConnection;3;1;1;2
WireConnection;4;0;1;3
WireConnection;4;1;1;4
WireConnection;6;0;3;0
WireConnection;6;1;5;2
WireConnection;27;0;26;0
WireConnection;28;0;29;0
WireConnection;28;1;30;0
WireConnection;12;0;9;0
WireConnection;7;0;5;2
WireConnection;7;1;4;0
WireConnection;39;1;37;0
WireConnection;39;0;28;0
WireConnection;40;0;27;0
WireConnection;11;0;10;0
WireConnection;11;1;6;0
WireConnection;13;0;12;0
WireConnection;13;1;7;0
WireConnection;21;1;13;0
WireConnection;41;0;33;0
WireConnection;41;1;39;0
WireConnection;41;2;40;0
WireConnection;14;1;11;0
WireConnection;16;1;15;0
WireConnection;16;0;9;3
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;22;2;16;0
WireConnection;22;3;46;0
WireConnection;44;0;41;0
WireConnection;44;1;42;0
WireConnection;44;2;45;0
WireConnection;44;3;14;0
WireConnection;0;2;44;0
WireConnection;0;10;22;0
ASEEND*/
//CHKSM=8D312F47C54C17471E6CDB650A3CD3721E2C562F