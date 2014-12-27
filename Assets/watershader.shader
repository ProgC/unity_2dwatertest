Shader "Custom/2DWaterShader" {
	Properties 
	{
		_TintColor ("Tint Color", Color) = (1.0, 1.0, 1.0, 1.0)		
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Background ("aaa", 2D) = "white" {}
		_AlphaValue ("alpha value", Range(0.0, 1.0)) = 1.0
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		//Blend ONE ONE
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaTest Greater .01
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off
		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		// ---- Fragment program cards
		SubShader {
			Pass 
			{				
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_particles
				
				#include "UnityCG.cginc"
	
				
				fixed4 _TintColor;
				float _AlphaValue;
								
				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};
				
				struct v2f {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;				
				};
							
				float4 _MainTex_ST;
				float4 _Background_ST;
							
				v2f vert (appdata_t v)
				{
					v2f o;
					//o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);				
					//o.color = v.color;
					//o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					
					v.vertex.xy = sign(v.vertex.xy);					
					o.vertex = float4( v.vertex.xy, 0.0, 1.0);
					// image space
					o.texcoord.x = 0.5 * (1 + v.vertex.x);
					o.texcoord.y = 0.5 * (1 + v.vertex.y);
					return o;
				}
						
				sampler2D _MainTex;
				sampler2D _Background;
																						
				fixed4 frag (v2f i) : COLOR
				{										
					float4 texColor = tex2D(_MainTex, i.texcoord);
					float4 backgroundColor = tex2D(_Background, i.texcoord);
					
					return texColor;
					//return texColor + backgroundCol;
				}
				ENDCG 
			}
		} 
	}
}
