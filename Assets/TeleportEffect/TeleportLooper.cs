using System.Collections;
using UnityEngine;

public class TeleportLooper : MonoBehaviour
{
    public float loopDuration = 2.0f;

    private Material _mat;
    private Coroutine loopCoroutine;

    private void Start()
    {
        Renderer renderer = GetComponent<Renderer>();
        if (renderer.material != null)
        {
            _mat = renderer.material;
            loopCoroutine = StartCoroutine(LoopTeleportEffect());
        }
        else
        {
            Debug.LogError("TeleportLooper: Material não encontrado.");
        }
    }

    private IEnumerator LoopTeleportEffect()
    {
        while (true)
        {
            yield return AnimateProgress(0f, 1f, loopDuration);

            yield return new WaitForSeconds(0.5f);
            
            yield return AnimateProgress(1f, 0f, loopDuration);
            
            yield return new WaitForSeconds(0.5f);
        }
    }

    private IEnumerator AnimateProgress(float start, float end, float duration)
    {
        float timer = 0f;
        while (timer < duration)
        {
            timer += Time.deltaTime;
            float progress = Mathf.Lerp(start, end, timer / duration);
            _mat.SetFloat("_Progress", progress);
            yield return null;
        }

        _mat.SetFloat("_Progress", end);
    }

    private void OnDestroy()
    {
        if (loopCoroutine != null)
        {
            StopCoroutine(loopCoroutine);
        }
    }
}