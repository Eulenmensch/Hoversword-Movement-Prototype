// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HeatDistortionParticle"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_rock_normal("rock_normal", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Range( 0 , 1)) = 0
		_RippleScale("RippleScale", Range( 0 , 20)) = 0
		_RippleSpeed("RippleSpeed", Range( 0 , 1)) = 0

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		GrabPass{ }

		Pass
		{ 
			CGPROGRAM 

			#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
			#else
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
			#endif


			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				float4 ase_texcoord4 : TEXCOORD4;
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
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
			


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float4 screenPos = i.ase_texcoord4;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float4 screenColor1 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( float4( ( UnpackNormal( tex2D( _rock_normal, ( _RippleScale * (( ( _Time.y * _RippleSpeed ) + ase_grabScreenPosNorm )).xyzw ).xy ) ) * _NormalStrength ) , 0.0 ) + ase_grabScreenPosNorm ).xy);
				

				finalColor = screenColor1;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18100
71;171;1379;816;2172.784;1093.048;2.705074;True;False
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
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;44;256.1272,-69.85349;Float;False;True;-1;2;ASEMaterialInspector;0;2;HeatDistortionParticle;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
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
WireConnection;44;0;1;0
ASEEND*/
//CHKSM=3CC12F5DBC0CB35AA3115831D670BD211F80A557