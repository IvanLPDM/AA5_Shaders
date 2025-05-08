inline float2 randomVector(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)) * 46839.32);
    return float2(sin(UV.y + offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

// Función para calcular los bordes de Voronoi con grosor uniforme
void VoronoiEdges_float(float2 UV, float AngleOffset, float CellDensity, float LineWidth, out float Edge)
{
    int2 cell = floor(UV * CellDensity);
    float2 posInCell = frac(UV * CellDensity);

    float minDist = 8.0;
    float2 closestOffset;

    // Buscar la celda más cercana
    for (int y = -1; y <= 1; ++y)
    {
        for (int x = -1; x <= 1; ++x)
        {
            int2 cellToCheck = int2(x, y);
            float2 cellOffset = float2(cellToCheck) - posInCell + randomVector(cell + cellToCheck, AngleOffset);

            float distToPoint = dot(cellOffset, cellOffset);

            if (distToPoint < minDist)
            {
                minDist = distToPoint;
                closestOffset = cellOffset;
            }
        }
    }

    minDist = 8.0;

    // Buscar la segunda celda más cercana y calcular la distancia al borde correcto
    for (int y = -1; y <= 1; ++y)
    {
        for (int x = -1; x <= 1; ++x)
        {
            int2 cellToCheck = int2(x, y);
            float2 cellOffset = float2(cellToCheck) - posInCell + randomVector(cell + cellToCheck, AngleOffset);

            float distToEdge = dot(0.5 * (closestOffset + cellOffset), normalize(cellOffset - closestOffset));

            minDist = min(minDist, distToEdge);
        }
    }

    // Aplicar suavizado para definir el grosor de los bordes
    Edge = 1.0 - smoothstep(0.0, LineWidth, minDist);
}