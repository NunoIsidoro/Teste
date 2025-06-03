Shader "WaterFlowTransition"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondTex ("Second Camera", 2D) = "white" {}
        _FlowMap ("Flow Map", 2D) = "gray" {}
        _Progress ("Transition Progress", Range(0, 1)) = 0
        _Distortion ("Water Distortion", Range(0, 1)) = 0.1
        _Speed ("Flow Speed", Range(0.1, 10)) = 1
        _EdgeSharpness ("Edge Sharpness", Range(1, 50)) = 10
        _WaveHeight ("Wave Height", Range(0, 1)) = 0.1
        _WaveFrequency ("Wave Frequency", Range(0, 50)) = 10
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex; // Primeira textura (imagem/câmera de origem)
            sampler2D _SecondTex; // Segunda textura (imagem/câmera de destino)
            sampler2D _FlowMap; // Mapa para a distorção da água
            float _Progress; // Progresso da transição
            float _Distortion; // Intensidade da distorção da água
            float _Speed; // Velocidade do movimento da água
            float _EdgeSharpness; // Nitides é a borda da água
            float _WaveHeight; // Altura das ondas
            float _WaveFrequency; // Frequência das ondas

            fixed4 frag (v2f i) : SV_Target
            {
                // Cálculo da posição da água
                // Faz o progresso oscilar fazendo o efeito de ida e volta da onda
                float pingPongProgress = 1.0 - abs(frac(_Progress) * 2 - 1);
                // Define até onde a água já "fluiu" na tela, baseado no UV vertical e no progresso
                float flowPosition = 1.0 - ((1.0 - i.uv.y) / (1.0 + pingPongProgress * 2.0));

                
                // Ondas
                // Adiciona efeito de onda à posição da água
                float wave = sin(i.uv.x * _WaveFrequency + _Time.y * _Speed) * _WaveHeight;
                flowPosition += wave;

                // Borda da água
                // Cria uma transição na borda da água
                float edge = saturate((flowPosition - (1.0 - pingPongProgress * 1.2)) * _EdgeSharpness);

                
                // Distorção com Flow Map
                // Usa o flow map para criar distorções na textura, simulando movimento de água
                float2 flowMapUV = i.uv;
                flowMapUV.y = flowMapUV.y * 0.5 + _Time.y * _Speed * 0.1;
                flowMapUV.x = flowMapUV.x * 0.5 + _Time.y * _Speed * 0.05;
                float2 flowVector = (tex2D(_FlowMap, flowMapUV).rg - 0.5) * 2.0;
                
                // Aplica distorção nos UVs
                // Só distorce onde há água
                float2 distortedUV = i.uv;
                distortedUV.x += flowVector.x * _Distortion * edge;
                distortedUV.y += flowVector.y * _Distortion * edge;
                
                // Amostragem das texturas
                fixed4 firstCam = tex2D(_MainTex, distortedUV);
                fixed4 secondCam = tex2D(_SecondTex, i.uv);
                
                // Máscara de transição
                float transitionMask = step(flowPosition, 0.0);
                fixed4 finalColor = lerp(firstCam, secondCam, transitionMask);
                
                // Realce na borda da água
                // Dá um brilho azul na borda da água
                float highlight = edge * (1.0 - edge) * 4.0; // Brighten the water edge
                finalColor.rgb += float3(0.2, 0.3, 0.4) * highlight * (1.0 - transitionMask);
                
                // Tonalidade azul na área coberta pela água
                float waterArea = saturate(flowPosition * 5.0) * (1.0 - transitionMask);
                finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb + float3(0.0, 0.05, 0.1), waterArea * 0.3);
                
                return finalColor;
            }
            ENDCG
        }
    }
}