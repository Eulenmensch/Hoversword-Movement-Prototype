// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ParticleSystem_Second"
{
	Properties
	{
		_Emission("Emission", Float) = 2
		_Opacity("Opacity", Range( 0 , 1)) = 1
		[Toggle(_KEYWORD0_ON)] _Keyword0("Keyword 0", Float) = 0
		[Toggle(_USECENTERGLOW_ON)] _UseCenterGlow("Use Center Glow", Float) = 0
		_DepthPower("Depth Power", Float) = 1
		_SpeedMainTexture("Speed Main Texture", Vector) = (0,0,0,0)
		_MainTex("Main Tex", 2D) = "white" {}
		_Noise("Noise", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
	LOD 100

		Cull Off
		CGINCLUDE
		#pragma target 3.0 
		ENDCG
		
		
		Pass
		{
			
			Name "ForwardBase"
			Tags { "LightMode"="ForwardBase" }

			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend Off
			Cull Back
			ColorMask RGBA
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#define UNITY_PASS_FORWARDBASE
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _USECENTERGLOW_ON
			#pragma shader_feature_local _KEYWORD0_ON

			uniform sampler2D _MainTex;
			uniform float4 _SpeedMainTexture;
			uniform sampler2D _Noise;
			uniform sampler2D _Mask;
			uniform float4 _Mask_ST;
			uniform float _Emission;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _DepthPower;
			uniform float _Opacity;


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
			};
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.pos = UnityObjectToClipPos(v.vertex);
				#if ASE_SHADOWS
					#if UNITY_VERSION >= 560
						UNITY_TRANSFER_SHADOW( o, v.texcoord );
					#else
						TRANSFER_SHADOW( o );
					#endif
				#endif
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
				float3 outColor;
				float outAlpha;

				float2 appendResult39 = (float2(_SpeedMainTexture.x , _SpeedMainTexture.y));
				float4 uv041 = i.ase_texcoord1;
				uv041.xy = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_47_0 = (uv041).xy;
				float4 tex2DNode54 = tex2D( _MainTex, ( ( appendResult39 * _Time.y ) + temp_output_47_0 ) );
				float2 appendResult40 = (float2(_SpeedMainTexture.z , _SpeedMainTexture.w));
				float4 tex2DNode55 = tex2D( _Noise, ( temp_output_47_0 + ( _Time.y * appendResult40 ) ) );
				float4 color58 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float3 temp_output_64_0 = ( (tex2DNode54).rgb * (tex2DNode55).rgb * (color58).rgb * (i.ase_color).rgb );
				float2 uv_Mask = i.ase_texcoord1.xy * _Mask_ST.xy + _Mask_ST.zw;
				float3 temp_output_66_0 = (tex2D( _Mask, uv_Mask )).rgb;
				float3 temp_cast_0 = ((0.0 + (uv041.z - 0.0) * (1.0 - 0.0) / (1.0 - 0.0))).xxx;
				float3 clampResult69 = clamp( ( temp_output_66_0 - temp_cast_0 ) , float3( 0,0,0 ) , float3( 1,0,0 ) );
				#ifdef _USECENTERGLOW_ON
				float3 staticSwitch33 = ( temp_output_64_0 * ( temp_output_66_0 * clampResult69 ) );
				#else
				float3 staticSwitch33 = temp_output_64_0;
				#endif
				
				float temp_output_27_0 = ( tex2DNode54.a * tex2DNode55.a * color58.a * i.ase_color.a );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth31 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth31 = abs( ( screenDepth31 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthPower ) );
				float clampResult30 = clamp( distanceDepth31 , 0.0 , 1.0 );
				#ifdef _KEYWORD0_ON
				float staticSwitch24 = ( temp_output_27_0 * clampResult30 );
				#else
				float staticSwitch24 = temp_output_27_0;
				#endif
				
				
				outColor = ( staticSwitch33 * _Emission );
				outAlpha = ( staticSwitch24 * _Opacity );
				clip(outAlpha);
				return float4(outColor,outAlpha);
			}
			ENDCG
		}
		
		
		Pass
		{
			Name "ForwardAdd"
			Tags { "LightMode"="ForwardAdd" }
			ZWrite Off
			Blend One One
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd_fullshadows
			#define UNITY_PASS_FORWARDADD
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _USECENTERGLOW_ON
			#pragma shader_feature_local _KEYWORD0_ON

			uniform sampler2D _MainTex;
			uniform float4 _SpeedMainTexture;
			uniform sampler2D _Noise;
			uniform sampler2D _Mask;
			uniform float4 _Mask_ST;
			uniform float _Emission;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _DepthPower;
			uniform float _Opacity;


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
			};
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.pos = UnityObjectToClipPos(v.vertex);
				#if ASE_SHADOWS
					#if UNITY_VERSION >= 560
						UNITY_TRANSFER_SHADOW( o, v.texcoord );
					#else
						TRANSFER_SHADOW( o );
					#endif
				#endif
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
				float3 outColor;
				float outAlpha;

				float2 appendResult39 = (float2(_SpeedMainTexture.x , _SpeedMainTexture.y));
				float4 uv041 = i.ase_texcoord1;
				uv041.xy = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_47_0 = (uv041).xy;
				float4 tex2DNode54 = tex2D( _MainTex, ( ( appendResult39 * _Time.y ) + temp_output_47_0 ) );
				float2 appendResult40 = (float2(_SpeedMainTexture.z , _SpeedMainTexture.w));
				float4 tex2DNode55 = tex2D( _Noise, ( temp_output_47_0 + ( _Time.y * appendResult40 ) ) );
				float4 color58 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float3 temp_output_64_0 = ( (tex2DNode54).rgb * (tex2DNode55).rgb * (color58).rgb * (i.ase_color).rgb );
				float2 uv_Mask = i.ase_texcoord1.xy * _Mask_ST.xy + _Mask_ST.zw;
				float3 temp_output_66_0 = (tex2D( _Mask, uv_Mask )).rgb;
				float3 temp_cast_0 = ((0.0 + (uv041.z - 0.0) * (1.0 - 0.0) / (1.0 - 0.0))).xxx;
				float3 clampResult69 = clamp( ( temp_output_66_0 - temp_cast_0 ) , float3( 0,0,0 ) , float3( 1,0,0 ) );
				#ifdef _USECENTERGLOW_ON
				float3 staticSwitch33 = ( temp_output_64_0 * ( temp_output_66_0 * clampResult69 ) );
				#else
				float3 staticSwitch33 = temp_output_64_0;
				#endif
				
				float temp_output_27_0 = ( tex2DNode54.a * tex2DNode55.a * color58.a * i.ase_color.a );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth31 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth31 = abs( ( screenDepth31 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthPower ) );
				float clampResult30 = clamp( distanceDepth31 , 0.0 , 1.0 );
				#ifdef _KEYWORD0_ON
				float staticSwitch24 = ( temp_output_27_0 * clampResult30 );
				#else
				float staticSwitch24 = temp_output_27_0;
				#endif
				
				
				outColor = ( staticSwitch33 * _Emission );
				outAlpha = ( staticSwitch24 * _Opacity );
				clip(outAlpha);
				return float4(outColor,outAlpha);
			}
			ENDCG
		}

		
		Pass
		{
			Name "Deferred"
			Tags { "LightMode"="Deferred" }

			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend Off
			Cull Back
			ColorMask RGBA
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_prepassfinal
			#define UNITY_PASS_DEFERRED
			#include "UnityCG.cginc"
			
			

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.pos = UnityObjectToClipPos(v.vertex);
				#if ASE_SHADOWS
					#if UNITY_VERSION >= 560
						UNITY_TRANSFER_SHADOW( o, v.texcoord );
					#else
						TRANSFER_SHADOW( o );
					#endif
				#endif
				return o;
			}
			
			void frag (v2f i , out half4 outGBuffer0 : SV_Target0, out half4 outGBuffer1 : SV_Target1, out half4 outGBuffer2 : SV_Target2, out half4 outGBuffer3 : SV_Target3)
			{
				
				
				outGBuffer0 = 0;
				outGBuffer1 = 0;
				outGBuffer2 = 0;
				outGBuffer3 = 0;
			}
			ENDCG
		}
		
		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }
			ZWrite On
			ZTest LEqual
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#define UNITY_PASS_SHADOWCASTER
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _USECENTERGLOW_ON
			#pragma shader_feature_local _KEYWORD0_ON

			uniform sampler2D _MainTex;
			uniform float4 _SpeedMainTexture;
			uniform sampler2D _Noise;
			uniform sampler2D _Mask;
			uniform float4 _Mask_ST;
			uniform float _Emission;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _DepthPower;
			uniform float _Opacity;


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
			};
			
			struct v2f
			{
				V2F_SHADOW_CASTER;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
			};

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_color = v.ase_color;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
				float3 outColor;
				float outAlpha;

				float2 appendResult39 = (float2(_SpeedMainTexture.x , _SpeedMainTexture.y));
				float4 uv041 = i.ase_texcoord1;
				uv041.xy = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_47_0 = (uv041).xy;
				float4 tex2DNode54 = tex2D( _MainTex, ( ( appendResult39 * _Time.y ) + temp_output_47_0 ) );
				float2 appendResult40 = (float2(_SpeedMainTexture.z , _SpeedMainTexture.w));
				float4 tex2DNode55 = tex2D( _Noise, ( temp_output_47_0 + ( _Time.y * appendResult40 ) ) );
				float4 color58 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float3 temp_output_64_0 = ( (tex2DNode54).rgb * (tex2DNode55).rgb * (color58).rgb * (i.ase_color).rgb );
				float2 uv_Mask = i.ase_texcoord1.xy * _Mask_ST.xy + _Mask_ST.zw;
				float3 temp_output_66_0 = (tex2D( _Mask, uv_Mask )).rgb;
				float3 temp_cast_0 = ((0.0 + (uv041.z - 0.0) * (1.0 - 0.0) / (1.0 - 0.0))).xxx;
				float3 clampResult69 = clamp( ( temp_output_66_0 - temp_cast_0 ) , float3( 0,0,0 ) , float3( 1,0,0 ) );
				#ifdef _USECENTERGLOW_ON
				float3 staticSwitch33 = ( temp_output_64_0 * ( temp_output_66_0 * clampResult69 ) );
				#else
				float3 staticSwitch33 = temp_output_64_0;
				#endif
				
				float temp_output_27_0 = ( tex2DNode54.a * tex2DNode55.a * color58.a * i.ase_color.a );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth31 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth31 = abs( ( screenDepth31 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthPower ) );
				float clampResult30 = clamp( distanceDepth31 , 0.0 , 1.0 );
				#ifdef _KEYWORD0_ON
				float staticSwitch24 = ( temp_output_27_0 * clampResult30 );
				#else
				float staticSwitch24 = temp_output_27_0;
				#endif
				
				
				outColor = ( staticSwitch33 * _Emission );
				outAlpha = ( staticSwitch24 * _Opacity );
				clip(outAlpha);
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
		
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18100
145;96;1443;798;2825.303;107.5418;1;True;True
Node;AmplifyShaderEditor.Vector4Node;36;-3821.442,-405.0757;Inherit;False;Property;_SpeedMainTexture;Speed Main Texture;5;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-3186.357,-389.7666;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;39;-3462.535,-503.629;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TimeNode;37;-3462.533,-382.4988;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;40;-3464.957,-202.015;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;47;-2923.508,-376.4424;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-3181.513,-208.0714;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-3187.57,-503.629;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;65;-2695.992,196.1262;Inherit;True;Property;_Mask;Mask;8;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;67;-2386.725,407.1041;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-2701.843,-228.6636;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-2703.055,-499.9951;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;66;-2370.192,196.1263;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;58;-2391.63,-247.0029;Inherit;False;Constant;_Color0;Color 0;8;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;54;-2439.172,-716.7416;Inherit;True;Property;_MainTex;Main Tex;6;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-2163.798,409.2844;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1586.99,364.9077;Inherit;False;Property;_DepthPower;Depth Power;4;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-2433.115,-480.5379;Inherit;True;Property;_Noise;Noise;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;60;-2351.161,-55.68814;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;31;-1365.34,346.7787;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;61;-1989.667,-429.3517;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;56;-1985.058,-609.6769;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;62;-1983.672,-258.2637;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;63;-1999.672,-110.2568;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;69;-2010.274,408.4529;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1020.875,45.05476;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1863.009,200.2196;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;30;-1072.16,336.4918;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1652.48,-392.7722;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-735.1389,153.5083;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1374.814,-60.50259;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;33;-1081.653,-269.804;Inherit;False;Property;_UseCenterGlow;Use Center Glow;3;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-483.816,169.8188;Inherit;False;Property;_Opacity;Opacity;1;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-373.816,-110.1812;Inherit;False;Property;_Emission;Emission;0;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;24;-453.816,42.81885;Inherit;False;Property;_Keyword0;Keyword 0;2;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-77.81604,13.81887;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-70.81603,-161.1812;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;76;199.3062,39.6806;Float;False;False;-1;2;ASEMaterialInspector;100;8;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;Deferred;0;2;Deferred;4;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Deferred;True;2;0;;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;74;196.9667,-126.6405;Float;False;True;-1;2;ASEMaterialInspector;100;8;ParticleSystem_Second;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ForwardBase;0;0;ForwardBase;3;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=ForwardBase;True;2;0;;0;0;Standard;0;0;4;True;True;True;True;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;75;196.9667,-16.6405;Float;False;False;-1;2;ASEMaterialInspector;100;8;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ForwardAdd;0;1;ForwardAdd;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;0;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;True;2;False;-1;False;False;True;1;LightMode=ForwardAdd;False;0;;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;77;215.6824,-104.4156;Float;False;False;-1;2;ASEMaterialInspector;100;1;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ShadowCaster;0;3;ShadowCaster;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;0
WireConnection;39;0;36;1
WireConnection;39;1;36;2
WireConnection;40;0;36;3
WireConnection;40;1;36;4
WireConnection;47;0;41;0
WireConnection;43;0;37;2
WireConnection;43;1;40;0
WireConnection;42;0;39;0
WireConnection;42;1;37;2
WireConnection;67;0;41;3
WireConnection;49;0;47;0
WireConnection;49;1;43;0
WireConnection;48;0;42;0
WireConnection;48;1;47;0
WireConnection;66;0;65;0
WireConnection;54;1;48;0
WireConnection;68;0;66;0
WireConnection;68;1;67;0
WireConnection;55;1;49;0
WireConnection;31;0;32;0
WireConnection;61;0;55;0
WireConnection;56;0;54;0
WireConnection;62;0;58;0
WireConnection;63;0;60;0
WireConnection;69;0;68;0
WireConnection;27;0;54;4
WireConnection;27;1;55;4
WireConnection;27;2;58;4
WireConnection;27;3;60;4
WireConnection;70;0;66;0
WireConnection;70;1;69;0
WireConnection;30;0;31;0
WireConnection;64;0;56;0
WireConnection;64;1;61;0
WireConnection;64;2;62;0
WireConnection;64;3;63;0
WireConnection;28;0;27;0
WireConnection;28;1;30;0
WireConnection;71;0;64;0
WireConnection;71;1;70;0
WireConnection;33;1;64;0
WireConnection;33;0;71;0
WireConnection;24;1;27;0
WireConnection;24;0;28;0
WireConnection;21;0;24;0
WireConnection;21;1;26;0
WireConnection;20;0;33;0
WireConnection;20;1;23;0
WireConnection;74;0;20;0
WireConnection;74;1;21;0
ASEEND*/
//CHKSM=733707064F12EA585B67F7D0D50932EE8A3B2495