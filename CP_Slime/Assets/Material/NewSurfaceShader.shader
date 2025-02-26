Shader "Custom/JellySlime"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 0.5) // Основной цвет с прозрачностью
        _FresnelPower ("Fresnel Power", Range(0, 5)) = 2.0 // Сила эффекта френеля
        _FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1) // Цвет френеля
        _Glossiness ("Glossiness", Range(0, 1)) = 0.5 // Глянцевость
        _DeformAmount ("Deform Amount", Range(0, 1)) = 0.1 // Сила деформации
        _DeformSpeed ("Deform Speed", Float) = 1.0 // Скорость деформации
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha // Включение прозрачности
            ZWrite Off // Отключение записи в буфер глубины для прозрачных объектов
            Cull Back // Отсечение задних граней

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

                // Деформация вершин (эффект желе)
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
                // Основной цвет текстуры
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Эффект френеля
                float fresnel = pow(1.0 - saturate(dot(i.worldNormal, i.viewDir)), _FresnelPower);
                float4 fresnelColor = _FresnelColor * fresnel;

                // Смешивание основного цвета и френеля
                float4 finalColor = texColor * _Color + fresnelColor;

                // Добавление глянца
                finalColor.rgb += fresnelColor.rgb * _Glossiness;

                // Прозрачность
                finalColor.a = _Color.a;

                return finalColor;
            }
            ENDCG
        }
    }
}