// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ParticleSystems_Shader"
{
	Properties
	{
		_Mask01("Mask01", 2D) = "white" {}
		_Mask02("Mask02", 2D) = "white" {}
		_Mask04("Mask04", 2D) = "white" {}
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureScale("Texture Scale", Float) = 1
		_MaskScale("Mask Scale", Float) = 1
		_Mask04Scale("Mask04 Scale", Float) = 1
		_Mask03Scale("Mask03 Scale", Float) = 1
		_Mask02Scale("Mask02 Scale", Float) = 1
		_TextureSpeed("Texture Speed", Float) = 0
		_Emission("Emission ", Float) = 1
		_MaskSpeed("Mask Speed", Float) = 0
		_Mask02Speed("Mask02 Speed", Float) = 0
		_Mask03Speed("Mask03 Speed", Float) = 0
		_Mask04Speed("Mask04 Speed", Float) = 0
		_MainTexture("MainTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTexture;
		uniform float _TextureSpeed;
		uniform float _TextureScale;
		uniform float _Emission;
		uniform sampler2D _Mask01;
		uniform float _MaskSpeed;
		uniform float _MaskScale;
		uniform sampler2D _Mask02;
		uniform float _Mask02Speed;
		uniform float _Mask02Scale;
		uniform sampler2D _TextureSample0;
		uniform float _Mask03Speed;
		uniform float _Mask03Scale;
		uniform sampler2D _Mask04;
		uniform float _Mask04Speed;
		uniform float _Mask04Scale;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 color53 = IsGammaSpace() ? float4(0,0.979579,1,0) : float4(0,0.9541724,1,0);
			float4 appendResult43 = (float4(0.0 , _TextureSpeed , 0.0 , 0.0));
			float2 panner41 = ( 1.0 * _Time.y * appendResult43.xy + ( _TextureScale * i.uv_texcoord ));
			o.Emission = ( color53 * tex2D( _MainTexture, panner41 ) * _Emission ).rgb;
			float4 appendResult46 = (float4(0.0 , _MaskSpeed , 0.0 , 0.0));
			float2 panner45 = ( 1.0 * _Time.y * appendResult46.xy + ( _MaskScale * i.uv_texcoord ));
			float4 appendResult61 = (float4(0.0 , _Mask02Speed , 0.0 , 0.0));
			float2 panner62 = ( 1.0 * _Time.y * appendResult61.xy + ( _Mask02Scale * i.uv_texcoord ));
			float4 appendResult68 = (float4(_Mask03Speed , 0.0 , 0.0 , 0.0));
			float2 panner69 = ( 1.0 * _Time.y * appendResult68.xy + ( _Mask03Scale * i.uv_texcoord ));
			float4 appendResult74 = (float4(_Mask04Speed , 0.0 , 0.0 , 0.0));
			float2 panner75 = ( 1.0 * _Time.y * appendResult74.xy + ( _Mask04Scale * i.uv_texcoord ));
			o.Alpha = ( tex2D( _Mask01, panner45 ) * tex2D( _Mask02, panner62 ) * tex2D( _TextureSample0, panner69 ) * tex2D( _Mask04, panner75 ) ).r;
		}

		ENDCG
	}
}
/*ASEBEGIN
Version=18100
73;373;1424;417;-230.9031;-403.1056;1.869806;True;True
Node;AmplifyShaderEditor.RangedFloatNode;40;723.5294,-1047.876;Inherit;False;Property;_TextureScale;Texture Scale;8;0;Create;True;0;0;False;0;False;1;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;706.9513,1025.433;Inherit;False;Property;_Mask04Speed;Mask04 Speed;18;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;713.0995,1122.479;Inherit;False;Property;_Mask04Scale;Mask04 Scale;10;0;Create;True;0;0;False;0;False;1;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;726.3177,467.6185;Inherit;False;Property;_Mask03Speed;Mask03 Speed;17;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;734.1866,-604.957;Inherit;False;Property;_MaskSpeed;Mask Speed;15;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;756.4495,-87.14378;Inherit;False;Property;_Mask02Speed;Mask02 Speed;16;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;762.5977,9.902287;Inherit;False;Property;_Mask02Scale;Mask02 Scale;12;0;Create;True;0;0;False;0;False;1;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;58;736.2988,127.0188;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;721.3813,-1140.922;Inherit;False;Property;_TextureSpeed;Texture Speed;13;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;714.0359,-390.7944;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;48;740.3347,-507.9109;Inherit;False;Property;_MaskScale;Mask Scale;9;0;Create;True;0;0;False;0;False;1;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;65;706.1671,681.7814;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;70;686.8007,1239.596;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;64;732.4659,564.6647;Inherit;False;Property;_Mask03Scale;Mask03 Scale;11;0;Create;True;0;0;False;0;False;1;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;694.6837,-933.5253;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;43;992.3394,-1120.541;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;1022.537,577.8165;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;987.8914,-957.614;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;1034.458,-313.1319;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;1052.669,23.05408;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;1026.589,759.4439;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;1030.406,-494.7591;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;74;1003.171,1135.631;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;1007.223,1317.258;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;1056.721,204.6813;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;62;1287.919,10.22759;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;41;1199.625,-1128.141;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;45;1262.952,-423.7696;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;69;1257.787,564.9901;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;75;1238.421,1122.804;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;53;1484.064,-1235.67;Inherit;False;Constant;_Color2;Color 2;10;0;Create;True;0;0;False;0;False;0,0.979579,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;1508.858,-51.5556;Inherit;True;Property;_Mask02;Mask02;5;0;Create;True;0;0;False;0;False;-1;None;fe7a9bc0753a14e4186b18f71074bed3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;76;1498.97,758.1752;Inherit;True;Property;_Mask04;Mask04;6;0;Create;True;0;0;False;0;False;-1;None;fe7a9bc0753a14e4186b18f71074bed3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;39;1395.958,-1036.275;Inherit;True;Property;_MainTexture;MainTexture;19;0;Create;True;0;0;False;0;False;-1;None;fe7a9bc0753a14e4186b18f71074bed3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;63;1518.336,200.3609;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;False;0;False;-1;None;fe7a9bc0753a14e4186b18f71074bed3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;1507.471,-313.0159;Inherit;True;Property;_Mask01;Mask01;4;0;Create;True;0;0;False;0;False;-1;None;fe7a9bc0753a14e4186b18f71074bed3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;1543.086,-814.3068;Inherit;False;Property;_Emission;Emission ;14;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;1142.941,-1654.237;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-1220.805,-1375.977;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;1928.157,-244.8726;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RelayNode;23;384.4993,-1464.193;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;18;-675.908,-1306.109;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;27;727.9452,-1610.05;Inherit;False;Constant;_Color1;Color 1;5;0;Create;True;0;0;False;0;False;0,0.8527436,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;953.4084,-1783.534;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1497.253,-1292.05;Inherit;False;Constant;_NoiseSpeed01;Noise Speed01;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1489.072,-694.6005;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;683.6895,-1694.028;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-309.8275,-1157.89;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;1463.787,-1673.836;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;1801.038,-1067.631;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;25;712.0504,-1879.781;Inherit;False;Constant;_Color0;Color 0;5;0;Create;True;0;0;False;0;False;1,0,0.3137255,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;33;540.1494,-1298.515;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;31;153.757,-1367.24;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;False;0;False;0.05;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-1218.7,-773.3099;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;17;-670.3549,-1090.369;Inherit;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;24;538.217,-1582.49;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-10.02181,-1469.335;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;16;-1010.967,-877.8371;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1225.253,-1213.05;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1515.552,-1083.135;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1.5,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-1495.105,-1199.004;Inherit;False;Constant;_NoiseScale1;Noise Scale 1;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1488.929,-790.1077;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;14;-987.8431,-1195.975;Inherit;True;Property;_Texture0;Texture 0;1;0;Create;True;0;0;False;0;False;959ac56afcbab1f4983f84daf4ef9f08;959ac56afcbab1f4983f84daf4ef9f08;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;952.1791,-1449.345;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;15;-1013.52,-1383.577;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1218.7,-884.3099;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;30;1204.049,-1889.818;Inherit;False;Property;_GlowColor;GlowColor;3;1;[HDR];Create;True;0;0;False;0;False;2.996078,0,0.5176471,0;11.98431,0,2.070588,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;177.841,-1589.533;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;False;0;False;0.1509341;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;20;-390.3846,-1635.915;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;False;0;False;-1;d9b938bec7a4c5e45a3c1adce6c3ded0;d9b938bec7a4c5e45a3c1adce6c3ded0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2187.699,-619.3134;Float;False;True;-1;2;;0;0;Unlit;ParticleSystems_Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;43;1;44;0
WireConnection;68;0;66;0
WireConnection;42;0;40;0
WireConnection;42;1;38;0
WireConnection;49;0;48;0
WireConnection;49;1;35;0
WireConnection;61;1;57;0
WireConnection;67;0;64;0
WireConnection;67;1;65;0
WireConnection;46;1;47;0
WireConnection;74;0;71;0
WireConnection;73;0;72;0
WireConnection;73;1;70;0
WireConnection;60;0;56;0
WireConnection;60;1;58;0
WireConnection;62;0;60;0
WireConnection;62;2;61;0
WireConnection;41;0;42;0
WireConnection;41;2;43;0
WireConnection;45;0;49;0
WireConnection;45;2;46;0
WireConnection;69;0;67;0
WireConnection;69;2;68;0
WireConnection;75;0;73;0
WireConnection;75;2;74;0
WireConnection;59;1;62;0
WireConnection;76;1;75;0
WireConnection;39;1;41;0
WireConnection;63;1;69;0
WireConnection;37;1;45;0
WireConnection;32;0;29;0
WireConnection;32;1;28;0
WireConnection;12;1;8;0
WireConnection;52;0;37;0
WireConnection;52;1;59;0
WireConnection;52;2;63;0
WireConnection;52;3;76;0
WireConnection;23;0;21;0
WireConnection;18;0;14;0
WireConnection;18;1;15;0
WireConnection;29;0;25;0
WireConnection;29;1;26;0
WireConnection;26;0;24;0
WireConnection;19;0;18;1
WireConnection;19;1;17;1
WireConnection;34;0;30;0
WireConnection;34;1;32;0
WireConnection;54;0;53;0
WireConnection;54;1;39;0
WireConnection;54;2;55;0
WireConnection;33;0;31;0
WireConnection;33;1;23;0
WireConnection;11;1;6;0
WireConnection;17;0;14;0
WireConnection;17;1;16;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;21;0;20;0
WireConnection;21;1;19;0
WireConnection;16;0;10;0
WireConnection;16;2;11;0
WireConnection;13;0;9;0
WireConnection;13;1;5;0
WireConnection;28;0;27;0
WireConnection;28;1;24;0
WireConnection;15;0;13;0
WireConnection;15;2;12;0
WireConnection;10;0;7;0
WireConnection;10;1;5;0
WireConnection;0;2;54;0
WireConnection;0;9;52;0
ASEEND*/
//CHKSM=3DB1C066E079117D43C1B7A4846E01E0BE221310