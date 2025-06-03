Shader "Unlit/ProjetoDeGrupoDesintegrar"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", Float) = 0

        _MainTex ("Main Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _RevealValue("Slider", Range(0, 1)) = 0
        _Feather("Feather", float) = 0

        [HDR] _ErodeColor("Erosde Color", color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _RevealValue, _Feather;
            float4 _ErodeColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                fixed4 mask = tex2D(_MaskTex, i.uv.zw);
                //float revealAmount = smoothstep(_RevealValue - _Feather, _RevealValue + _Feather, mask.r);
                float revealAmountTop = step(_RevealValue, mask.r + _Feather);
                float revealAmountBottom = step(_RevealValue, mask.r - _Feather);
                float revealDifference = revealAmountTop - revealAmountBottom;
                float3 finalCol = lerp(col.rgb, _ErodeColor, revealDifference);
                //return fixed4(revealDifference.xxx, 1);
                return fixed4(finalCol.rgb, col.a * revealAmountTop);
            }
            ENDCG
        }
    }
}
