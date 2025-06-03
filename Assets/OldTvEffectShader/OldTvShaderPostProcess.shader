Shader "Unlit/OldTvShaderPostProcess"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _EffectTex ("Effect Texture", 2D) = "white" {}
        _ScrollSpeed ("Vertical Scroll Speed", Float) = 0.5
        _Transparency ("Transparency", Range(0, 1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _EffectTex;
            float4 _EffectTex_ST;
            float _ScrollSpeed;
            float _Transparency;

            fixed4 frag(v2f_img i) : SV_Target
            {
                float2 uv = i.uv;

                float2 effectUV = TRANSFORM_TEX(uv, _EffectTex);
                effectUV.y += _Time.y * _ScrollSpeed;
                effectUV.y = frac(effectUV.y);

                fixed4 col = tex2D(_MainTex, uv);
                fixed4 effectCol = tex2D(_EffectTex, effectUV);

                effectCol.a *= _Transparency;
                col.rgb = lerp(col.rgb, effectCol.rgb, effectCol.a);

                return col;
            }
            ENDCG
        }
    }
    FallBack Off
}