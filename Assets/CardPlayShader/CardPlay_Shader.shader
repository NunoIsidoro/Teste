Shader "Unlit/CardPlay_Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BackTex ("Back Texture", 2D) = "white" {}
        _ProgressSlider ("Progress", Range(0, 1)) = 0
        _ScaleFactor ("Scale Factor", Float) = 0
        _FadeColor ("Fade Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            Cull Back
            
            CGPROGRAM
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ProgressSlider;
            float _ScaleFactor;
            fixed4 _FadeColor;

            v2f vert (appdata v)
            {
                v2f o;

                float4 fakeVert = v.vertex;
                fakeVert.y = v.vertex.y * (1+_ProgressSlider * _ScaleFactor);
                fakeVert.x = v.vertex.x * (1+_ProgressSlider * _ScaleFactor);
                
                o.vertex = UnityObjectToClipPos(fakeVert);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float colorProgress = saturate(_ProgressSlider * 5);
                fixed4 fadedColor = lerp(fixed4(1, 1, 1, 1), _FadeColor, colorProgress);

                col.rgb *= fadedColor.rgb;
                col.a = 1 - _ProgressSlider;
                return col;
            }
            ENDCG
        }

        Pass
        {
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _BackTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_BackTex, i.uv);
            }
            ENDCG
        }
    }
}
