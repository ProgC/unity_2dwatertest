Shader "Custom/metaBallShader" {
	Properties 
	{
		_TintColor ("Tint Color", Color) = (1.0, 1.0, 1.0, 1.0)		
		_EdgeColor ("Edge Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Base (RGB)", 2D) = "white" {}	
		_NoiseTex ("NoiseTexture", 2D) = "white" {}	
		_BackgroundTex ("RTBackground", 2D) = "white" {}
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite On
		ColorMask RGB

		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		// ---- Fragment program cards
		SubShader 
		{
			// GrabPass take a current view and make it into RenderTexture
			/*GrabPass
			{
				Name "BASE"
				Tags { "LightMode" = "Always" }
			}*/

			Pass 
			{				
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_particles
				
				#include "UnityCG.cginc"
				
				fixed4 _TintColor;
				fixed4 _EdgeColor;

				//sampler2D _GrabTexture : register(s0);
				sampler2D _MainTex;
				sampler2D _NoiseTex;
				sampler2D _BackgroundTex;
										
				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};
				
				struct v2f {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					float2 uvmain : TEXCOORD1;
					float4 screenPos : TEXCOORD2;
				};
							
				float4 _MainTex_ST;
				float4 _NoiseTex_ST;
				float4 _BackgroundTex_ST;
				
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.uvmain = TRANSFORM_TEX(v.texcoord, _NoiseTex);

					//o.uvmain.y *= -1;
					o.screenPos = o.vertex;
					//o.screenPos.y *= -1.0f;

					return o;
				}
				
				fixed4 frag (v2f i) : COLOR
				{			
					half4 texcol,finalColor;
					texcol = tex2D (_MainTex, i.texcoord); 		
					finalColor = _TintColor * texcol;

					half4 offsetColor1 = tex2D(_NoiseTex, i.uvmain + _Time.xz * 0.4);
					half4 offsetColor2 = tex2D(_NoiseTex, i.uvmain - _Time.yx * 0.4);
   
					// use the r values from the noise texture lookups and combine them for x offset
					// use the g values from the noise texture lookups and combine them for y offset
					// use minus one to shift the texture back to the center
					// scale with distortion amount
					
					// range from -1 to 1
					float2 screenPos = i.screenPos.xy / i.screenPos.w;
					screenPos.x = (screenPos.x + 1 ) * 0.5f;					
					screenPos.y = (screenPos.y + 1 ) * 0.5f;
										
					screenPos.x += ((offsetColor1.r + offsetColor2.r) - 1) * 0.02f;
					screenPos.y += ((offsetColor1.g + offsetColor2.g) - 1) * 0.01f;

					float4 backgroundColor = tex2D(_BackgroundTex, screenPos);

					if ( finalColor.a == 0 )
					{
						backgroundColor.argb = 0;
						finalColor.argb = 0;						
					}
					else if (finalColor.a > 0.2)
					{
						if ( finalColor.a <= 0.3 )
						{
							finalColor = _EdgeColor;
							
							backgroundColor.argb = 1;
						}
						else
						{
							finalColor.a = 0.5;
							finalColor.a = 1;
							backgroundColor.a = 1;

							finalColor.b = floor((finalColor.b/0.1)*0.5);
						}
					}

					float4 result = backgroundColor * finalColor;
					return result;
				}
				ENDCG 
			}
		} 
	}
}
