using System.Collections;
using UnityEngine;
using UnityEngine.Serialization;

public class ShockEffectLooper : MonoBehaviour
{
    [Header("Área de Spawn")]
    public Vector2 AreaX = new Vector2(-5f, 5f);
    public Vector2 AreaZ = new Vector2(-5f, 5f);
    
    [Header("Character")]
    public Transform Character;

    [Header("Configuração")]
    public float DropHeight = 5f;
    public float TempoEntreQuedas = 2f;

    private Rigidbody _rb;

    private void Start()
    {
        _rb = Character.GetComponent<Rigidbody>();
        StartCoroutine(LoopShockEffect());
    }

    private IEnumerator LoopShockEffect()
    {
        while (true)
        {
            Vector3 novaPos = new Vector3(
                Random.Range(AreaX.x, AreaX.y),
                DropHeight,
                Random.Range(AreaZ.x, AreaZ.y)
            );

            Character.position = novaPos;

            _rb.linearVelocity = Vector3.zero;
            _rb.angularVelocity = Vector3.zero;

            yield return new WaitForSeconds(TempoEntreQuedas);
        }
    }
}