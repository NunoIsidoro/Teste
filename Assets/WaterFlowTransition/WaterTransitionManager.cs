using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class WaterTransitionManager : MonoBehaviour
{
    public Camera firstCamera;
    public Camera secondCamera;

    [Header("Transition Settings")]
    public float transitionDuration = 2.0f;
    [Range(0, 1)] public float distortion = 0.2f;
    public float flowSpeed = 2.0f;
    public float edgeSharpness = 20f;
    public float waveHeight = 0.05f;
    public float waveFrequency = 20f;
    public Shader transitionShader;
    
    [Header("Textures")]
    public Texture2D flowMap;

    private Material transitionMaterial;
    private RenderTexture firstCameraRT;
    private RenderTexture secondCameraRT;
    private RenderTexture tempRenderTexture;

    private bool isTransitioning = false;
    private float transitionProgress = 0f;
    private Camera thisCamera;

    private bool usingFirstCamera = true;

    private void Start()
    {
        thisCamera = GetComponent<Camera>();

        if (thisCamera == firstCamera || thisCamera == secondCamera)
        {
            Debug.LogError("WaterTransitionManager deve estar numa câmara separada das câmaras de origem e destino.");
        }

        if (firstCamera == null || secondCamera == null)
        {
            Debug.LogError("As câmaras firstCamera e secondCamera devem estar atribuídas.");
            return;
        }

        // Desliga ambas as câmaras no início
        firstCamera.enabled = true;
        secondCamera.enabled = false;

        transitionMaterial = new Material(transitionShader);
        if (transitionMaterial == null)
        {
            Debug.LogError("Shader 'WaterFlowTransition' não encontrado.");
            return;
        }

        firstCameraRT = new RenderTexture(Screen.width, Screen.height, 24);
        secondCameraRT = new RenderTexture(Screen.width, Screen.height, 24);
        tempRenderTexture = new RenderTexture(Screen.width, Screen.height, 24);

        if (flowMap == null)
        {
            Debug.LogWarning("Sem flow map. A gerar mapa ruído por defeito.");
            flowMap = GenerateNoiseTexture(256, 256);
        }

        transitionMaterial.SetTexture("_FlowMap", flowMap);
    }

    private void Update()
    {
        if (Input.GetKeyDown("f"))
        {
            StartTransition();
        }
    }

    private void StartTransition()
    {
        if (!isTransitioning)
        {
            StartCoroutine(TransitionCoroutine());
        }
    }

    private IEnumerator TransitionCoroutine()
    {
        isTransitioning = true;
        transitionProgress = 0f;

        Camera origin = usingFirstCamera ? firstCamera : secondCamera;
        Camera target = usingFirstCamera ? secondCamera : firstCamera;
        RenderTexture originRT = usingFirstCamera ? firstCameraRT : secondCameraRT;
        RenderTexture targetRT = usingFirstCamera ? secondCameraRT : firstCameraRT;

        origin.targetTexture = originRT;
        target.targetTexture = targetRT;
        target.enabled = true;

        origin.Render();
        target.Render();

        bool cameraSwitched = false;

        while (transitionProgress < 1.0f)
        {
            transitionProgress += Time.deltaTime / transitionDuration;

            if (!cameraSwitched && transitionProgress >= 0.5f)
            {
                origin.enabled = false;
                origin.targetTexture = null;

                target.enabled = true;
                target.targetTexture = null;

                cameraSwitched = true;
            }

            yield return null;
        }

        usingFirstCamera = !usingFirstCamera;
        isTransitioning = false;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!isTransitioning || !firstCamera || !secondCamera)
        {
            Graphics.Blit(src, dest);
            return;
        }

        Camera origin = usingFirstCamera ? firstCamera : secondCamera;
        Camera target = usingFirstCamera ? secondCamera : firstCamera;
        RenderTexture originRT = usingFirstCamera ? firstCameraRT : secondCameraRT;
        RenderTexture targetRT = usingFirstCamera ? secondCameraRT : firstCameraRT;

        origin.Render();
        target.Render();

        transitionMaterial.SetTexture("_MainTex", src);
        transitionMaterial.SetTexture("_SecondTex", targetRT);
        transitionMaterial.SetFloat("_Progress", transitionProgress);
        transitionMaterial.SetFloat("_Distortion", distortion);
        transitionMaterial.SetFloat("_Speed", flowSpeed);
        transitionMaterial.SetFloat("_EdgeSharpness", edgeSharpness);
        transitionMaterial.SetFloat("_WaveHeight", waveHeight);
        transitionMaterial.SetFloat("_WaveFrequency", waveFrequency);

        Graphics.Blit(originRT, tempRenderTexture, transitionMaterial);
        Graphics.Blit(tempRenderTexture, dest);
    }

    void OnDestroy()
    {
        if (firstCameraRT != null) firstCameraRT.Release();
        if (secondCameraRT != null) secondCameraRT.Release();
        if (tempRenderTexture != null) tempRenderTexture.Release();

        if (transitionMaterial != null)
            Destroy(transitionMaterial);
    }

    private Texture2D GenerateNoiseTexture(int width, int height)
    {
        Texture2D texture = new Texture2D(width, height);

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                float r = Random.Range(0.3f, 0.7f);
                float g = Random.Range(0.3f, 0.7f);
                texture.SetPixel(x, y, new Color(r, g, 0, 1));
            }
        }

        texture.Apply();
        return texture;
    }
}
