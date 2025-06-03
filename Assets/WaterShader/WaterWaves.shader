Shader "Custom/AdvancedWaterVertFrag"
{
    Properties
    {
        _WaterColor ("Water Color", Color) = (0, 0.5, 1, 1)
        _WaveHeight ("Wave Height", Float) = 0.1
        _WaveFrequency ("Wave Frequency", Float) = 1.0
        _WaveSpeed ("Wave Speed", Float) = 1.0
        _Normal1 ("Detail Normal Map", 2D) = "bump" {}
        _Normal2 ("Base Normal Map", 2D) = "bump" {}
        _NoiseTex ("Noise Texture (Foam)", 2D) = "white" {}
        _Normal1Tiling ("Normal1 Tiling", Float) = 1.0
        _Normal2Tiling ("Normal2 Tiling", Float) = 1.0
        _FoamThreshold ("Foam Threshold", Float) = 0.5
        _FoamIntensity ("Foam Intensity", Float) = 0.05
        _LavaColor ("Lava Color", Color) = (1, 0.3, 0, 1)
        _CrackColor ("Crack Color", Color) = (1, 1, 0.5, 1)
        _EmissionStrength ("Emission Strength", Float) = 2.0
        _IsLava ("Is Lava (0=Water, 1=Lava)", Range(0,1)) = 0
    }
    
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 300
        
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            // Properties
            sampler2D _Normal1;
            sampler2D _Normal2;
            sampler2D _NoiseTex;
            float4 _Normal1_ST;
            float4 _Normal2_ST;
            float4 _NoiseTex_ST;
            
            float _WaveHeight;
            float _WaveFrequency;
            float _WaveSpeed;
            float _Normal1Tiling;
            float _Normal2Tiling;
            float _FoamThreshold;
            float _FoamIntensity;
            fixed4 _WaterColor;
            fixed4 _LavaColor;
            fixed4 _CrackColor;
            float _EmissionStrength;
            float _IsLava;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv_Normal1 : TEXCOORD0;
                float2 uv_Normal2 : TEXCOORD1;
                float2 uv_NoiseTex : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                float3 worldNormal : TEXCOORD4;
                float3 worldTangent : TEXCOORD5;
                float3 worldBinormal : TEXCOORD6;
                float waveFactor : TEXCOORD7;
                LIGHTING_COORDS(8, 9)
            };
            
            v2f vert(appdata v)
            {
                v2f o;
                
                // Calculate waves
                float wave = sin(_WaveFrequency * v.vertex.x + _Time.y * _WaveSpeed) + 
                            cos(_WaveFrequency * v.vertex.z + _Time.y * _WaveSpeed);
                v.vertex.y += wave * _WaveHeight;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                // Calculate UVs
                o.uv_Normal1 = v.uv * _Normal1Tiling;
                o.uv_Normal2 = v.uv * _Normal2Tiling;
                o.uv_NoiseTex = v.uv + float2(_Time.y * 0.1, _Time.y * 0.05);
                
                // World space vectors for normal mapping
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                
                o.waveFactor = abs(wave);
                
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                // Sample normal maps
                float3 n1 = UnpackNormal(tex2D(_Normal1, i.uv_Normal1));
                float3 n2 = UnpackNormal(tex2D(_Normal2, i.uv_Normal2));
                float3 normalMap = normalize(n1 + n2);
                
                // Transform normal to world space
                float3 worldNormal = normalize(
                    normalMap.x * i.worldTangent +
                    normalMap.y * i.worldBinormal +
                    normalMap.z * i.worldNormal
                );
                
                // Sample noise texture for foam/cracks
                float noise = tex2D(_NoiseTex, i.uv_NoiseTex).r;
                float mask = smoothstep(_FoamThreshold, 1.0, noise + i.waveFactor);
                
                // Water properties
                float3 waterFoam = lerp(_WaterColor.rgb, float3(1,1,1), mask * _FoamIntensity);
                float waterSmooth = 0.85;
                float waterAlpha = 0.9;
                
                // Lava properties
                float3 lavaCrack = lerp(_LavaColor.rgb, _CrackColor.rgb, mask * _FoamIntensity * 2);
                float lavaSmooth = 0.4;
                float lavaAlpha = 1.0;
                float3 lavaEmission = lavaCrack * mask * _EmissionStrength;
                
                // Blend based on _IsLava
                float3 albedo = lerp(waterFoam, lavaCrack, _IsLava);
                float smoothness = lerp(waterSmooth, lavaSmooth, _IsLava);
                float alpha = lerp(waterAlpha, lavaAlpha, _IsLava);
                float3 emission = lerp(float3(0,0,0), lavaEmission, _IsLava);
                
                // Simple lighting calculation
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfDir = normalize(lightDir + viewDir);
                
                float NdotL = max(0, dot(worldNormal, lightDir));
                float NdotH = max(0, dot(worldNormal, halfDir));
                
                // Specular calculation (simplified PBR)
                float roughness = 1.0 - smoothness;
                float spec = pow(NdotH, (1.0 - roughness) * 128.0) * smoothness;
                
                // Final color calculation
                float3 diffuse = albedo * _LightColor0.rgb * NdotL;
                float3 specular = _LightColor0.rgb * spec * 0.5;
                float3 ambient = ShadeSH9(float4(worldNormal, 1.0)) * albedo;
                
                float3 finalColor = diffuse + specular + ambient + emission;
                
                // Apply lighting attenuation
                float atten = LIGHT_ATTENUATION(i);
                finalColor *= atten;
                
                return fixed4(finalColor, alpha);
            }
            ENDCG
        }
    }
    
    FallBack "Transparent/Diffuse"
}