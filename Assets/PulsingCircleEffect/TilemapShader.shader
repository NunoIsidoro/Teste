Shader "Custom/PulsingCircleEffect_Shader"
{
    Properties
    {
        // --- Main Texture ---
        [Header(Main Texture)] [Space]
        _MainTex ("Tile Set (RGB)", 2D) = "white" {}
        _TileIndex ("Tile Index", Float) = 0
        _TileQuantity ("Tile Quantity", Float) = 15
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            // --- Shader Variables ---
            sampler2D _MainTex;
            float _TileIndex;
            float _TileQuantity;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // --- Tile Texture ---
                float finalUVX = i.uv.x / _TileQuantity;
                finalUVX += (1 / _TileQuantity) * _TileIndex;
                float4 c = tex2D(_MainTex, float2(finalUVX, i.uv.y));

                return c;
            }

            ENDCG
        }
    }
}
