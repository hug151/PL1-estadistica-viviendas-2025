# Cómo ejecutar el proyecto

1. Descomprimir la carpeta completa y abrir `PL1.Rproj` en RStudio.
2. Abrir `analisis.R`. El CSV original debe permanecer en la misma carpeta.
3. Ejecutar las líneas en orden con Ctrl+Intro, o usar Source para ejecutar todo.
4. Consultar las tablas y las tres imágenes de la carpeta `resultados`.

## Relación con las prácticas

- **Práctica 1:** asignaciones con `=`, lectura con `read.csv2`, extracción de columnas con `$`, filtros y vectores.
- **Práctica 2:** funciones de centralización, dispersión y posición; cuartiles e IQR de tipo 2; funciones de moda, asimetría y curtosis definidas en el material; histogramas y cajas.
- **Práctica 3:** `tapply` para calcular medidas según Tipo; `cut`, `table`, `prop.table` y `addmargins` para las tablas; gráficos de barras.
- **Práctica 4:** estructura del informe, muestra completa y dos grupos, tablas, figuras, interpretación y conclusiones.

Material: https://hilera.web.uah.es/estadistica/r/index.html

## Decisiones del estudio

Se eliminan primero todas las filas con Valor=0. Quedan 239 registros: 166 de segunda mano y 73 de vivienda nueva. Cada registro representa un municipio y un tipo de vivienda durante el cuarto trimestre de 2025. La columna Todos reúne esos registros; no es el total de ventas agregado de cada municipio.

Se usa `encoding="UTF-8"` porque el CSV contiene tildes y `dec="."` porque sus decimales tienen punto. La primera cabecera se renombra a Anio para evitar problemas con su tilde y la marca BOM. No se modifica la configuración regional del ordenador.

No se necesita instalar paquetes. Las tres funciones propias son las operaciones presentadas en la práctica 2. La asimetría y la curtosis usan la desviación típica muestral, equivalentes al tipo 3 de e1071.

Los gráficos conservan los datos originales, incluidos los valores extremos. Sus paneles tienen escalas diferentes; deben leerse los ejes. Las cajas utilizan las bisagras de Tukey de `boxplot`, que pueden diferir de los cuartiles tipo 2 de la tabla.

No se calcula correlación con Tipo: es una variable cualitativa, y asignarle números arbitrarios no sería adecuado. Se usa la parte de la práctica 3 dedicada a comparar una variable cuantitativa según una cualitativa.

