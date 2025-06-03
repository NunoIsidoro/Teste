using System.Collections;
using UnityEngine;
using UnityEngine.Serialization;

public class PaletteSwapperLooper : MonoBehaviour
{
    private Material _mat;

    public Texture2D[] Palettes; // Lista de paletes a alternar
    public float Interval = 2f;  // Tempo entre cada troca

    private int _currentIndex = 0;

    private void Start()
    {
        if (Palettes == null || Palettes.Length == 0)
        {
            Debug.LogWarning("Nenhuma palete atribuída ao PaletteSwapperLooper.");
            return;
        }

        _mat = GetComponent<Renderer>().material;
        StartCoroutine(CyclePalettes());
    }

    private IEnumerator CyclePalettes()
    {
        while (true)
        {
            _mat.SetTexture("_SelectedPalette", Palettes[_currentIndex]);

            _currentIndex = (_currentIndex + 1) % Palettes.Length;

            yield return new WaitForSeconds(Interval);
        }
    }
}
