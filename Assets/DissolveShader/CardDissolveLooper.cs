using System.Collections;
using UnityEngine;
using UnityEngine.Serialization;

public class CardDissolveLooper : MonoBehaviour
{
    private Material _material;
    public float Duration = 2f;

    private void Start()
    {
        _material = GetComponent<Renderer>().material;
        StartCoroutine(LoopDissolve());
    }

    private IEnumerator LoopDissolve()
    {
        while (true)
        {
            yield return AnimateDissolve(-0.2f, 1f, Duration);

            yield return new WaitForSeconds(0.5f);

            yield return AnimateDissolve(1f, -0.2f, Duration);

            yield return new WaitForSeconds(0.5f);
        }
    }

    private IEnumerator AnimateDissolve(float from, float to, float time)
    {
        var elapsed = 0f;

        while (elapsed < time)
        {
            var t = elapsed / time;
            var progress = Mathf.Lerp(from, to, t);
            _material.SetFloat("_RevealValue", progress);

            elapsed += Time.deltaTime;
            yield return null;
        }

        _material.SetFloat("_RevealValue", to);
    }
}