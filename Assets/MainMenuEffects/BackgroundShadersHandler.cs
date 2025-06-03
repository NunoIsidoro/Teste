using UnityEngine;

public class BackgroundShadersHandler : MonoBehaviour
{
    [SerializeField] private GameObject _blackBackground;
    [SerializeField] private GameObject _radialRaysBackground;
    [SerializeField] private GameObject _loadingBackground;
    [SerializeField] private GameObject _mixedBackground;
    
    void Start()
    {
        DisableAllBackgrounds();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha0))
        {
            DisableAllBackgrounds();
        }

        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            EnableOnly(_radialRaysBackground);
        }

        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            EnableOnly(_loadingBackground);
        }

        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            EnableOnly(_mixedBackground);
        }
    }

    void DisableAllBackgrounds()
    {
        _blackBackground?.SetActive(false);
        _radialRaysBackground?.SetActive(false);
        _loadingBackground?.SetActive(false);
        _mixedBackground?.SetActive(false);
    }

    void EnableOnly(GameObject background)
    {
        DisableAllBackgrounds();
        _blackBackground?.SetActive(true);
        background?.SetActive(true);
    }
}
