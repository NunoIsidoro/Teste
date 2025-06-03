Shader "Hidden/CardDissolveShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BackTex ("Back Texture", 2D) = "white" {}
        _DistortionTex ("Distortion", 2D) = "white" {}
        _DissolveSlider ("_DissolveSlider", Range(-0.2, 1)) = -0.2
        _ColorOne ("Color One", Color) = (1,1,1,1)
        _ColorTwo ("Color Two", Color) = (1,1,1,1)
    }
   SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _BackTex;
            sampler2D _DistortionTex;
            float _DissolveSlider;

            float4 _ColorOne, _ColorTwo;

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
                float4 col = tex2D(_BackTex, i.uv);
                float4 distortion = tex2D(_DistortionTex, i.uv);

                // Aplica o mesmo efeito de dissolve para a textura traseira
                if (distance(distortion.rgb, float3(0,0,0)) < 0.01 && _DissolveSlider > -0.2)
                {
                    col.a = 0;
                }
                else if (distortion.r < _DissolveSlider)
                {
                    col.a = 0;
                }
                else if (distortion.r < _DissolveSlider + 0.02)
                {
                    col = lerp(_ColorOne, _ColorTwo, (distortion.r - _DissolveSlider) / 0.02);
                }
                else if (distortion.r < _DissolveSlider + 0.04)
                {
                    col = lerp(_ColorTwo, float4(0,0,0,1), (distortion.r - _DissolveSlider - 0.02) / 0.02);
                }
                
                return col;
            }
            ENDCG
        }

        Pass
        {
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _DistortionTex;
            float _DissolveSlider;

            float4 _ColorOne, _ColorTwo;

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
                float4 col = tex2D(_MainTex, i.uv);
                float4 distortion = tex2D(_DistortionTex, i.uv);

                if (distance(distortion.rgb, float3(0,0,0)) < 0.01 && _DissolveSlider > -0.2)
                {
                    col.a = 0;
                }
                else if (distortion.r < _DissolveSlider)
                {
                    col.a = 0;
                }
                else if (distortion.r < _DissolveSlider + 0.02)
                {
                    col = _ColorTwo;
                }
                else if (distortion.r < _DissolveSlider + 0.04)
                {
                    col = _ColorOne;
                }
                
                return col;
            }
            ENDCG
        }
    }
}
