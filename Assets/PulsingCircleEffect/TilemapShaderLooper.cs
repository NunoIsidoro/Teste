using System.Collections;
using UnityEngine;

public class TilemapShaderLooper : MonoBehaviour
{
    public float interval = 1.0f;
    public int maxIndex = 15;

    private Material _mat;
    private Coroutine loopCoroutine;
    private int currentIndex = 0;

    private void Start()
    {
        Renderer renderer = GetComponent<Renderer>();
        if (renderer.material != null)
        {
            _mat = renderer.material;
            loopCoroutine = StartCoroutine(LoopTileIndex());
        }
        else
        {
            Debug.LogError("TilemapShaderLooper: Material não encontrado.");
        }
    }

    private IEnumerator LoopTileIndex()
    {
        while (true)
        {
            _mat.SetFloat("_TileIndex", currentIndex);
            currentIndex = (currentIndex + 1) % (maxIndex + 1);
            yield return new WaitForSeconds(interval);
        }
    }

    private void OnDestroy()
    {
        if (loopCoroutine != null)
        {
            StopCoroutine(loopCoroutine);
        }
    }
}