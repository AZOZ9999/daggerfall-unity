Shader "Daggerfall/RetroPosterization"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SkyTex ("Sky Texture", any) = "" {}
	}
	SubShader
	{
		// No culling or depth
		Lighting Off
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		ZWrite On
		ZTest Always
		Fog { Mode Off }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			#define gamma 2.0

			struct appdata
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 screenPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			sampler2D _SkyTex;
			uniform float4 _SkyTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// Sample sky colour and leave as-is
				float4 skyColor = tex2D(_SkyTex, i.texcoord).rgba;

				fixed4 col = tex2D(_MainTex, i.texcoord).rgba;
				// Decrease color depth to 4 bits per component
				fixed4 textureColor = fixed4(pow(round(pow(col.rgb, 1/gamma) * 16.0) / 16.0, gamma), col.a);

				// Draw sky where world is not using 0.1f alpha threshold
				if (textureColor.a < 0.1f)
					return skyColor;
				else
					return textureColor;
			}
			ENDCG
		}
	}
    
    Fallback Off
}
