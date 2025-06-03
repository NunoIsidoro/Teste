Shader "Custom/TeleportFlash_Sprite"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex("Noise (R)", 2D) = "white" {}
        _SparkTex("Sparkle (RGB)", 2D) = "white" {}
        _Progress("Progress", Range(0, 1)) = 0
        _EdgeColor("Edge Color", Color) = (0.1, 0.8, 1, 1)
        _EdgeWidth("Edge Width", Range(0, 0.25)) = 0.07
        _SparkInt("Sparkle Intensity", Range(0, 5)) = 2
        _GlowStrength("Glow Strength (HDR)", Range(0, 8)) = 3
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" "PreviewType"="Plane" }
        LOD 100
        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex, _NoiseTex, _SparkTex;
            float4 _MainTex_ST;
            float _Progress, _EdgeWidth, _SparkInt, _GlowStrength;
            fixed4 _EdgeColor;

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float alpha = col.a;

                float progress = saturate(_Progress);
                float gate = progress * (1.0 - progress) * 4.0;

                float stripe = 1.0 - i.uv.y;
                float noise = tex2D(_NoiseTex, i.uv * 4).r;
                float mask = lerp(stripe, noise, 0.6);
                float cut = mask - progress;

                if (cut < 0) discard;

                float edge = smoothstep(0.0, _EdgeWidth, cut);
                float edgeFactor = edge * gate;
                col.rgb = lerp(col.rgb, _EdgeColor.rgb, edgeFactor);

                float2 spUV = i.uv * float2(1, 8) + float2(0, progress * 2);
                fixed3 sp = tex2D(_SparkTex, spUV).rgb;
                float sparkleMask = saturate(1.0 - edge) * gate;
                col.rgb += sp * sparkleMask * _SparkInt;

                fixed3 glow = (_EdgeColor.rgb * _GlowStrength + sp * _SparkInt) * sparkleMask;

                col.rgb += glow;
                col.a = alpha;

                return col;
            }
            ENDCG
        }
    }
}
