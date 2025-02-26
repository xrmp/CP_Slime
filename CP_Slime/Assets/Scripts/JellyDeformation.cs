using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class JellyDeformation : MonoBehaviour
{
    [SerializeField] private float stiffness = 10f; // Ƹ������� ����
    [SerializeField] private float damping = 5f;   // �������������
    [SerializeField] private float mass = 1f;      // ����� �������

    [SerializeField] private float deformAmount = 0.1f; // ���� ����������
    [SerializeField] private float deformSpeed = 1.0f;  // �������� ����������

    private Mesh originalMesh;
    private Mesh deformedMesh;
    private Vector3[] vertices;
    private Vector3[] velocities;

    private Material material;

    void Start()
    {
        originalMesh = GetComponent<MeshFilter>().mesh;
        deformedMesh = Instantiate(originalMesh);
        GetComponent<MeshFilter>().mesh = deformedMesh;

        vertices = deformedMesh.vertices;
        velocities = new Vector3[vertices.Length];

        // �������� ��������
        material = GetComponent<Renderer>().material;
    }

    void Update()
    {
        // ��������� ���������� ������
        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 displacement = vertices[i] - originalMesh.vertices[i];
            Vector3 force = -stiffness * displacement - damping * velocities[i];
            velocities[i] += force / mass * Time.deltaTime;
            vertices[i] += velocities[i] * Time.deltaTime;
        }

        deformedMesh.vertices = vertices;
        deformedMesh.RecalculateNormals();

        // ������� ��������� ���������� � ������
        material.SetFloat("_DeformAmount", deformAmount);
        material.SetFloat("_DeformSpeed", deformSpeed);
    }
}