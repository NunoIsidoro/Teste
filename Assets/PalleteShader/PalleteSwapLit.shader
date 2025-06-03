Shader "Custom/PaletteSwapLit"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _OriginPalette("Origin Palette", 2D) = "white" {}
        _SelectedPalette("Selected Palette", 2D) = "white" {}
        _ColorQuantity("Color Quantity", Int) = 16
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        CGPROGRAM
        #pragma surface surf Lambert alpha
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _OriginPalette;
        sampler2D _SelectedPalette;
        int _ColorQuantity;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            
            for (int j = 0; j < 16; j++)
            {
                float2 originUV = float2(j / (_ColorQuantity * 1.0), 0.5);
                fixed4 originColor = tex2D(_OriginPalette, originUV);

                if (originColor.a == 0) break;
                
                if (distance(c.rgb, originColor.rgb) < 0.01)
                {
                    float2 targetUV = float2(j / (_ColorQuantity * 1.0), 0.5);
                    c.rgb = tex2D(_SelectedPalette, targetUV).rgb;
                    break;
                }
            }
            
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
            
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
}
