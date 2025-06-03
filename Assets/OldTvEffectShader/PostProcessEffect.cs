using UnityEngine;

namespace OldTvEffectShader
{
    [ExecuteInEditMode]
    public class ScrollingPostProcess : MonoBehaviour
    {
        public Shader Shader;
        public Texture2D EffectTexture;
        [Range(0, 1)] public float Transparency = 1.0f;
        public float ScrollSpeed = 0.5f;

        private Material _material;

        private void Start()
        {
            if (Shader == null)
                Shader = Shader.Find("Hidden/ScrollingPostProcess");

            if (Shader != null)
                _material = new Material(Shader);
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (_material == null)
            {
                Graphics.Blit(src, dest);
                return;
            }

            _material.SetTexture("_EffectTex", EffectTexture);
            _material.SetFloat("_Transparency", Transparency);
            _material.SetFloat("_ScrollSpeed", ScrollSpeed);

            Graphics.Blit(src, dest, _material);
        }
    }
}