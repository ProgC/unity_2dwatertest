Shader "Custom/edgeDetector" {
	Properties 
	{
		_TintColor ("Tint Color", Color) = (1.0, 1.0, 1.0, 1.0)		
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
	
		AlphaTest Greater 0
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off
		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		// ---- Fragment program cards
		SubShader 
		{
			Pass 
			{				
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_particles
				
				#include "UnityCG.cginc"
				
				fixed4 _TintColor;								
				sampler2D _MainTex;				
										
				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};
				
				struct v2f {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;				
				};
							
				float4 _MainTex_ST;				
				
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);										
					return o;
				}
				
				fixed4 frag (v2f i) : COLOR
				{										
					float4 mainTex = tex2D(_MainTex, i.texcoord);

					float off = 1.0f / 1024.0f;
					
					float s00 = tex2D( _MainTex, i.texcoord + float2(-off, -off) );
					float s01 = tex2D( _MainTex, i.texcoord + float2( 0, -off) );
					float s02 = tex2D( _MainTex, i.texcoord + float2( off, -off) );

					float s10 = tex2D( _MainTex, i.texcoord + float2( -off, 0) );
					float s12 = tex2D( _MainTex, i.texcoord + float2( off, 0) );

					float s20 = tex2D( _MainTex, i.texcoord + float2( -off, off) );
					float s21 = tex2D( _MainTex, i.texcoord + float2( 0, off) );
					float s22 = tex2D( _MainTex, i.texcoord + float2( off, off) );
															
					// Sobel filter in X direction
					float sobelX = s00 + 2 * s10 + s20 - s02 - 2 * s12 - s22;

					// Sobel filter in Y direction
					float sobelY = s00 + 2 * s01 + s02 - s20 - 2 * s21 - s22;

					// Find edge, skip sqrt() to improve performance ...
					float edgeSqr = (sobelX * sobelX + sobelY * sobelY);

					// ... and threshold against a squared value instead.
					//float4 color = 1.0 - (edgeSqr > 0.07 * 0.07);
					//return color;
					
					if ( edgeSqr > 0.08 * 0.08 )
					{
						return float4(0,0,1,1);
					}
					else
					{
						return mainTex;
					}
   										
					//float2 texCoord = i.texcoord;					
					//return mainTex;
				}
				ENDCG 
			}
		} 
	}
}
