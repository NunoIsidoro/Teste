using System.Collections;
using UnityEngine;
using UnityEngine.Serialization;

public class CardPlayLooper : MonoBehaviour
{
    private Material _material;
    public float Duration = 1.5f;

    private void Start()
    {
        _material = GetComponent<Renderer>().material;
        StartCoroutine(LoopProgress());
    }

    private IEnumerator LoopProgress()
    {
        while (true)
        {
            yield return AnimateProgress(0f, 1f, Duration);
            yield return AnimateProgress(1f, 0f, Duration);
        }
    }

    private System.Collections.IEnumerator AnimateProgress(float from, float to, float time)
    {
        var elapsed = 0f;

        while (elapsed < time)
        {
            var t = elapsed / time;
            var progress = Mathf.Lerp(from, to, t);
            _material.SetFloat("_ProgressSlider", progress);

            elapsed += Time.deltaTime;
            yield return null;
        }

        _material.SetFloat("_ProgressSlider", to);
    }
}
