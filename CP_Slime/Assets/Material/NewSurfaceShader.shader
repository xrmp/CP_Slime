Shader "Custom/JellySlime"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 0.5) // �������� ���� � �������������
        _FresnelPower ("Fresnel Power", Range(0, 5)) = 2.0 // ���� ������� �������
        _FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1) // ���� �������
        _Glossiness ("Glossiness", Range(0, 1)) = 0.5 // �����������
        _DeformAmount ("Deform Amount", Range(0, 1)) = 0.1 // ���� ����������
        _DeformSpeed ("Deform Speed", Float) = 1.0 // �������� ����������
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha // ��������� ������������
            ZWrite Off // ���������� ������ � ����� ������� ��� ���������� ��������
            Cull Back // ��������� ������ ������

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _Color;
            float _FresnelPower;
            float4 _FresnelColor;
            float _Glossiness;
            float _DeformAmount;
            float _DeformSpeed;

            v2f vert (appdata v)
            {
                v2f o;

                // ���������� ������ (������ ����)
                float deformation = sin(v.vertex.x * 10.0 + _Time.y * _DeformSpeed) * _DeformAmount;
                v.vertex.xyz += deformation * normalize(v.vertex.xyz);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // �������� ���� ��������
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // ������ �������
                float fresnel = pow(1.0 - saturate(dot(i.worldNormal, i.viewDir)), _FresnelPower);
                float4 fresnelColor = _FresnelColor * fresnel;

                // ���������� ��������� ����� � �������
                float4 finalColor = texColor * _Color + fresnelColor;

                // ���������� ������
                finalColor.rgb += fresnelColor.rgb * _Glossiness;

                // ������������
                finalColor.a = _Color.a;

                return finalColor;
            }
            ENDCG
        }
    }
}