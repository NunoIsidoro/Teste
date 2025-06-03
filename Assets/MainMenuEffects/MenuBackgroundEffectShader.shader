Shader "Custom/RadialRaysSimple"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RotationSpeed ("Rotation Speed", Float) = 1.0
        _RayColor ("Ray Color", Color) = (0.2, 0.8, 0.8, 0.8)
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
            
            float _RotationSpeed;
            fixed4 _RayColor;
            
            #define PI 3.14159265359
            #define TWO_PI 6.28318530718
            
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
                // Get screen coordinates
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float2 fragCoord = screenUV * _ScreenParams.xy;
                float2 resolution = _ScreenParams.xy;
                float2 uv = (fragCoord - resolution * 0.5) / min(resolution.x, resolution.y);
                
                // Calculate distance and angle
                float dist = length(uv);
                float angle = atan2(uv.y, uv.x);
                angle += _Time.y * _RotationSpeed;
                
                // Create 16 rays with 40% width
                float normalizedAngle = (angle + PI) / TWO_PI;
                float raySegment = normalizedAngle * 16.0;
                float rayMask = step(frac(raySegment), 0.4);
                
                // Center circle (radius 0.15)
                float centerMask = step(dist, 0.15);
                
                // Ray fade from center
                float fadeFactor = 1.0 - smoothstep(0.2, 1.0, dist);
                
                // Final color
                fixed4 backgroundColor = fixed4(0.1, 0.6, 0.6, 1);
                fixed4 centerColor = _RayColor;
                
                fixed4 finalColor = backgroundColor;
                
                if (centerMask > 0.5) {
                    finalColor = centerColor;
                } else {
                    finalColor = lerp(backgroundColor, _RayColor, rayMask * fadeFactor);
                }
                
                return finalColor;
            }
            ENDCG
        }
    }
    
    FallBack "Sprites/Default"
}