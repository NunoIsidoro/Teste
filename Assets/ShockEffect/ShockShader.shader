Shader "Unlit/ShockShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Center ("Shock Center", Vector) = (0.5, 0.5, 0, 0)
        _TimeParam ("Shock Time", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _Center;
            float _TimeParam;

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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float getOffsetStrength(float t, float2 dir, float2 aspect) {
                float maxRadius = 0.5;
                float d = length(dir / aspect) - t * maxRadius;
                d *= (1.0 - smoothstep(0.0, 0.05, abs(d)));
                d *= smoothstep(0.0, 0.05, t);
                d *= (1.0 - smoothstep(0.5, 1.0, t));
                return d;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 dir = _Center - uv;

                float2 aspect = float2(_ScreenParams.x / _ScreenParams.y, 1.0);

                float tOffset = 0.05 * sin(_TimeParam * 3.14159);
                float rD = getOffsetStrength(_TimeParam + tOffset, dir, aspect);
                float gD = getOffsetStrength(_TimeParam, dir, aspect);
                float bD = getOffsetStrength(_TimeParam - tOffset, dir, aspect);

                float2 normDir = normalize(dir);

                float r = tex2D(_MainTex, uv + normDir * rD).r;
                float g = tex2D(_MainTex, uv + normDir * gD).g;
                float b = tex2D(_MainTex, uv + normDir * bD).b;

                float shading = gD * 8.0;

                return float4(r, g, b, 1.0) + float4(shading, shading, shading, 0.0);
            }

            ENDCG
        }
    }
}
