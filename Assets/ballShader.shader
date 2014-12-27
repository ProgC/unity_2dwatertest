Shader "Custom/ballShader" {
	Properties 
	{
		_TintColor ("Tint Color", Color) = (1.0, 1.0, 1.0, 1.0)		
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NoiseTex ("NoiseTexture", 2D) = "white" {}
		_AlphaValue ("alpha value", Range(0.0, 1.0)) = 1.0
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		//Blend ONE ONE
		Blend SrcAlpha OneMinusSrcAlpha
		//Blend ONE OneMinusSrcAlpha
		//Blend SrcAlpha ONE		
		
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
			GrabPass 
			{
				Name "BASE"
				Tags { "LightMode" = "Always" }
			}			

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
				
				sampler2D _GrabTexture : register(s0);		
				sampler2D _MainTex;				
				sampler2D _NoiseTex;
						
				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};
				
				struct v2f {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float2 uvmain : TEXCOORD1;
					float4 screenPos : TEXCOORD2;
				};
							
				float4 _MainTex_ST;				
				float4 _NoiseTex_ST;		
				
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
					o.uvmain = TRANSFORM_TEX(v.texcoord, _NoiseTex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					
					o.screenPos = o.vertex;
					o.screenPos.y *= -1.0f;
					
					return o;
				}
				
				fixed4 frag (v2f i) : COLOR
				{										
					float4 mainTex = tex2D(_MainTex, i.texcoord);
					
					float2 texCoord = i.texcoord;					
					
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
					
					float4 grabTextureColor = tex2D(_GrabTexture, screenPos);
					
					float4 mainColor = mainTex;
					
					/*if ( mainColor.x >= 0.3f )
					{
						mainColor = float4(1,1,1,1);
					}
					else
					{
						mainColor = float4(0,0,0,0);
					}
					
					return grabTextureColor * mainColor * _TintColor;*/


					half4 texcol,finalColor;

					texcol = tex2D (_MainTex, i.texcoord);
					finalColor = _AlphaValue*texcol;
					if(finalColor.a>0.2){
						finalColor.a=0.5;
						finalColor.b=floor((finalColor.b/0.1)*0.5);
					}			
					//return finalColor;
					return texcol;
					
					//return mainColor;
				}
				ENDCG 
			}
		} 
	}
}
