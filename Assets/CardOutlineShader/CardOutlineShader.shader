Shader "Hidden/CardOutlineShader"
{
    Properties
    {
        [Header(Textures)]
        _MainTex ("Front Texture", 2D) = "white" {}
        _BackTex ("Back Texture", 2D) = "white" {}
        
        [Header(Outline)]
        _OutlineColor ("Outline Color", Color) = (1,1,1,1)
        _OutlineWidth ("Outline Width", Range(0, 10)) = 1
        
        [Header(Noise)]
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _RotateSpeed ("Rotate Speed", Range(0, 100)) = 20
        _Len ("Rotate Direction", Range(-1, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        // Pass 1: back face
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

        // Pass 2: Outline front face
        Pass
        {
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _OutlineColor;
            float _OutlineWidth;
            sampler2D _NoiseTex;
            float _RotateSpeed;
            float _Len;

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
                float3 offset = normalize(v.vertex.xyz) * _OutlineWidth;
                v.vertex.xyz += offset;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv.xy - float2(0.5, 0.5);
                uv = float2(
                    uv.x * cos(_RotateSpeed * _Time.x * _Len) - uv.y * sin(_RotateSpeed * _Time.x * _Len),
                    uv.x * sin(_RotateSpeed * _Time.x * _Len) + uv.y * cos(_RotateSpeed * _Time.x * _Len)
                );
                uv += float2(0.5, 0.5);
                
                float4 c = tex2D(_NoiseTex, uv);
                c *= _OutlineColor * 1.5;
                return c;
            }
            ENDCG
        }

        // Pass 3: Default front face
        Pass
        {
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

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
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
