Shader "Daggerfall/RetroTestOnly"
{
    Properties
    {
        _MainTex("Texture", any) = "" {}
        _SkyTex("Sky Texture", any) = "" {}
    }

        SubShader{

            Lighting Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite On
            Fog { Mode Off }
            ZTest Always

            Pass {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata_t {
                    float4 vertex : POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord : TEXCOORD0;
                };

                struct v2f {
                    float4 vertex : SV_POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord : TEXCOORD0;
                    float2 screenPos : TEXCOORD1;
                };

                sampler2D _MainTex;
                uniform float4 _MainTex_ST;
                sampler2D _SkyTex;
                uniform float4 _SkyTex_ST;

                v2f vert(appdata_t v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.color = v.color;
                    o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
                    o.screenPos = ComputeScreenPos(o.vertex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    // Sample sky colour and leave as-is
                    float4 skyColor = tex2D(_SkyTex, i.texcoord).rgba;

                    // Sample texture colour and run through postprocessing
                    // Tinting world red as a hack to simulate postprocessing
                    float4 textureColor = tex2D(_MainTex, i.texcoord).rgba;
                    textureColor = textureColor * float4(1, 0, 0, 1);

                    // Draw sky where world is not using 0.1f alpha threshold
                    if (textureColor.a < 0.1f)
                        return skyColor;
                    else
                        return textureColor;
                }
                ENDCG
            }
        }

            Fallback off
}