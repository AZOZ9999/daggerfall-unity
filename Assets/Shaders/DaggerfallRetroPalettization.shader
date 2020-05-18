﻿Shader "Daggerfall/RetroPalettization"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Lut ("Texture", 3D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
       Lighting Off 
		Cull Off ZWrite Off ZTest Always
       Fog { Mode Off } 

		Pass
		{
			CGPROGRAM
           #pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
            sampler3D _Lut;
            
	        fixed4 frag (v2f i) : SV_Target
	        {
                // Explore color space!
                //float3 target = float3(i.uv, frac(_Time.x));
                
                float3 target = tex2D(_MainTex, i.uv);
                
                fixed4 col = tex3D(_Lut, target);
                return col;
            }
			ENDCG
		}
	}
}
