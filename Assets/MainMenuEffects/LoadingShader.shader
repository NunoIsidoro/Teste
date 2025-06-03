Shader "Custom/LoadingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        // Scale controls
        _Scale1 ("Scale 1 (X, Y, Z)", Vector) = (15, 0.4, 0.975, 0)
        _Scale2 ("Scale 2 (X, Y, Z)", Vector) = (25, 0.8, 0.5, 0)
        _Scale3 ("Scale 3 (X, Y, Z)", Vector) = (75, 3.2, 0.8, 0)
        
        // Color controls
        _Color1 ("Color 1", Color) = (1, 0.67256093, 0, 1)
        _Color2 ("Color 2", Color) = (1, 0.7411765, 0, 1)
        _Color3 ("Color 3", Color) = (1, 0.7411765, 0, 1)
        _BaseColor ("Base Color", Color) = (1, 0.8078432, 0, 1)
        
        // Time multiplier
        _TimeMultiplier ("Time Multiplier", Float) = 1.0
        
        // Alpha control
        _Alpha ("Alpha", Range(0, 1)) = 1.0
    }
    
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            
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
                float4 screenPos : TEXCOORD1;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float3 _Scale1;
            float3 _Scale2;
            float3 _Scale3;
            
            fixed4 _Color1;
            fixed4 _Color2;
            fixed4 _Color3;
            fixed4 _BaseColor;
            
            float _TimeMultiplier;
            float _Alpha;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float2 fragCoord = screenUV * _ScreenParams.xy;
                
                float2 iResolution = _ScreenParams.xy;
                float iTime = _Time.y * _TimeMultiplier;
                
                float pos = length((fragCoord - iResolution.xy * 0.5) / iResolution.yy);
                
                float f1 = sin(pos * _Scale1.x - iTime * _Scale1.y);
                float f2 = sin(pos * _Scale2.x - iTime * _Scale2.y);
                float f3 = sin(pos * _Scale3.x - iTime * _Scale3.y);
                
                float3 col = _BaseColor.rgb;
                
                if (f1 > _Scale1.z) {
                    col = _Color1.rgb;
                }              
                else if (f2 > _Scale2.z) {
                    col = _Color2.rgb;
                }
                else if (f3 > _Scale3.z) {
                    col = _Color3.rgb;
                }
                
                return fixed4(col, _Alpha);
            }
            ENDCG
        }
    }
    
    FallBack "Sprites/Default"
}