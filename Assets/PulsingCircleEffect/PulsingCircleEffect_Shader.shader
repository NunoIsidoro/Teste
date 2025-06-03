Shader "Custom/PulsingCircleEffect_Shader"
{
    Properties
    {
        // --- Main Texture ---
        [Header(Main Texture)] [Space]
        _MainTex ("Tile Set (RGB)", 2D) = "white" {}
        _TileIndex ("Tile Index", Float) = 0
        _TileQuantity ("Tile Quantity", Float) = 15

        [Header(Pulsing Circle Effect)] [Space]
        
        [Toggle]
        _EnablePulsingCircleEffect ("Enable Pulsing Circle Effect", Float) = 0
        
        // --- Circle Effect Settings ---
        _CircleTex ("Circle Texture", 2D) = "white" {}
        _Color ("Effect Color", Color) = (1, 1, 1, 1)
        _IntensityMin ("Min Intensity", Range(0, 1)) = 0.3
        _IntensityMax ("Max Intensity", Range(0, 1)) = 1
    
        // --- Zoom and Speed Controls ---
        _ZoomScaleMax ("Max Zoom Scale", Range(1, 5)) = 1.5
        _ZoomSpeed ("Zoom Speed", Range(0, 10)) = 1
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
            sampler2D _CircleTex;
            float _TileIndex;
            float _TileQuantity;
            float _EnablePulsingCircleEffect;
            float _IntensityMin;
            float _IntensityMax;
            float4 _Color;
            float _ZoomScaleMax;
            float _ZoomSpeed;

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

                // --- Oscillation Calculation ---
                float oscillation = (sin(_Time.y * _ZoomSpeed) + 1.0) * 0.5;

                // --- Zoom and Intensity ---
                float zoom = lerp(1.0, _ZoomScaleMax, oscillation);
                float intensity = lerp(_IntensityMin, _IntensityMax, oscillation);

                // --- Circle Effect Calculation ---
                if (_EnablePulsingCircleEffect > 0.5)
                {
                    float2 center = float2(0.5, 0.5);
                    float2 uv = (i.uv - center) * zoom + center;

                    float4 circleColor = tex2D(_CircleTex, uv);
                    circleColor.rgb *= _Color.rgb;

                    c.rgb = lerp(c.rgb, circleColor.rgb , circleColor.a * intensity);
                }

                return c;
            }

            ENDCG
        }
    }
}
