# PL1: viviendas vendidas por municipio, cuarto trimestre de 2025.
# Abrir PL1.Rproj en RStudio y ejecutar este archivo desde el principio.
# P1: lectura y filtros. P2: medidas y graficos. P3: grupos y tablas.
# https://hilera.web.uah.es/estadistica/r/index.html

# 1. LECTURA Y LIMPIEZA (P1)
# El archivo tiene columnas separadas por ; y decimales con punto.
datos = read.csv2("transacciones_vivienda_municipios_2025_T4.csv",
                  dec = ".", encoding = "UTF-8")
# Se simplifica la cabecera del ano para evitar problemas con la tilde y el BOM.
names(datos)[1] = "Anio"
# Eliminar todos los ceros ANTES de realizar el estudio.
datos = datos[datos$Valor != 0, ]
write.csv2(datos, "datos_sin_ceros.csv", row.names = FALSE, fileEncoding = "UTF-8")
ventas = datos$Valor
tipo = datos$Tipo
segunda = ventas[tipo == "Segunda mano"]
nueva = ventas[tipo == "Vivienda nueva"]
length(ventas)  # 239 registros, no 239 viviendas.
table(tipo)     # 166 registros de segunda mano y 73 de vivienda nueva.
sort(ventas)
sort(segunda)
sort(nueva)

# 2. FUNCIONES DE LA PRACTICA 2 (sin instalar paquetes)
moda = function(x) {
  u = unique(x)
  m = match(x, u)
  t = tabulate(m)
  return(u[t == max(t)])
}
# Formulas equivalentes a skewness/kurtosis de e1071, tipo 3.
asimetria = function(x) {
  n = length(x)
  return(sum((x - mean(x))^3) / n / sd(x)^3)
}
curtosis = function(x) {
  n = length(x)
  return(sum((x - mean(x))^4) / n / sd(x)^4 - 3)
}

# 3. MEDIDAS DEL TOTAL Y POR TIPO (P2 y P3)
# Cada columna reune un resultado de Todos y los dos resultados de tapply.
# Todos contiene registros municipio-tipo; NO suma ventas por municipio.
medidas = data.frame(
  n = c(length(ventas), tapply(ventas, tipo, length)),
  Total = c(sum(ventas), tapply(ventas, tipo, sum)),
  Media = c(mean(ventas), tapply(ventas, tipo, mean)),
  Mediana = c(median(ventas), tapply(ventas, tipo, median)),
  Moda = c(moda(ventas), tapply(ventas, tipo, moda)),
  Minimo = c(min(ventas), tapply(ventas, tipo, min)),
  Maximo = c(max(ventas), tapply(ventas, tipo, max)),
  Varianza = c(var(ventas), tapply(ventas, tipo, var)),
  Desviacion = c(sd(ventas), tapply(ventas, tipo, sd)),
  Asimetria = c(asimetria(ventas), tapply(ventas, tipo, asimetria)),
  Curtosis = c(curtosis(ventas), tapply(ventas, tipo, curtosis)),
  row.names = c("Todos", "Segunda mano", "Vivienda nueva")
)
# Cuartiles e IQR de tipo 2, como indica la practica 2.
medidas$Q1 = c(quantile(ventas, 0.25, type = 2),
              tapply(ventas, tipo, quantile, probs = 0.25, type = 2))
medidas$Q3 = c(quantile(ventas, 0.75, type = 2),
              tapply(ventas, tipo, quantile, probs = 0.75, type = 2))
medidas$RIC = c(IQR(ventas, type = 2), tapply(ventas, tipo, IQR, type = 2))
medidas$Rango = medidas$Maximo - medidas$Minimo
medidas$CV = medidas$Desviacion / medidas$Media
# Registros por debajo y por encima de la media DE SU GRUPO.
medidas$Inferiores = c(length(ventas[ventas < mean(ventas)]),
                       length(segunda[segunda < mean(segunda)]),
                       length(nueva[nueva < mean(nueva)]))
medidas$Superiores = c(length(ventas[ventas > mean(ventas)]),
                       length(segunda[segunda > mean(segunda)]),
                       length(nueva[nueva > mean(nueva)]))
medidas$Iguales = medidas$n - medidas$Inferiores - medidas$Superiores
print(round(medidas, 2))

# 4. TABLAS DE CONTINGENCIA (P2 y P3)
# [1,11) equivale a 1-10 porque las ventas son numeros enteros.
limites = c(1, 11, 51, 101, 501, max(ventas) + 1)
intervalo = cut(ventas, breaks = limites, right = FALSE,
                labels = c("1-10", "11-50", "51-100", "101-500", "501 o mas"))
tabla = table(intervalo, tipo)
addmargins(tabla)
round(addmargins(prop.table(tabla)), 4)  # Frecuencias respecto al total.
round(100 * prop.table(tabla, 2), 2)    # Porcentajes dentro de cada tipo.
categoria = cut(ventas, breaks = c(1, 11, 101, max(ventas) + 1),
                right = FALSE, labels = c("1-10", "11-100", "101 o mas"))
tabla3 = table(categoria, tipo)
addmargins(tabla3)
porcentajes3 = 100 * prop.table(tabla3, 2)
round(porcentajes3, 2)

# 5. GUARDAR RESULTADOS
# Estas instrucciones solo sirven para conservar las tablas y los graficos.
dir.create("resultados", showWarnings = FALSE)
write.csv2(medidas, "resultados/resumen_completo.csv")
write.csv2(medidas, "resultados/medidas.csv")
write.csv2(as.data.frame.matrix(tabla), "resultados/contingencia.csv")
write.csv2(addmargins(prop.table(tabla)), "resultados/frecuencias_relativas.csv")
write.csv2(100 * prop.table(tabla, 2), "resultados/porcentajes.csv")
write.csv2(as.data.frame.matrix(tabla3), "resultados/contingencia_3.csv")
write.csv2(porcentajes3, "resultados/porcentajes_3.csv")
capture.output(sort(ventas), sort(segunda), sort(nueva),
               file = "resultados/muestras_ordenadas.txt")

# 6. GRAFICOS (P2 y P3)
# png abre una imagen y dev.off termina de guardarla.
png("resultados/composicion.png", width = 1200, height = 700, res = 140)
barplot(100 * prop.table(table(tipo)), ylim = c(0, 100),
         col = c("lightblue", "orange"), ylab = "Registros (%)",
         main = "Figura 1. Composicion de la muestra sin ceros")
dev.off()
# Escala original, sin logaritmos. Cada panel tiene su propia escala.
png("resultados/histogramas_cajas.png", width = 2100, height = 1400, res = 170)
par(mfrow = c(2, 3), mar = c(5, 4, 3, 1))
hist(ventas, col = "lightblue", main = "Todos",
      xlab = "Viviendas por municipio y tipo", ylab = "Registros")
abline(v = median(ventas), lwd = 2)
abline(v = mean(ventas), col = "red", lty = 2, lwd = 2)
hist(segunda, col = "lightblue", main = "Segunda mano",
      xlab = "Viviendas por municipio", ylab = "Registros")
abline(v = median(segunda), lwd = 2)
abline(v = mean(segunda), col = "red", lty = 2, lwd = 2)
hist(nueva, col = "orange", main = "Vivienda nueva",
      xlab = "Viviendas por municipio", ylab = "Registros")
abline(v = median(nueva), lwd = 2)
abline(v = mean(nueva), col = "red", lty = 2, lwd = 2)
boxplot(ventas, col = "lightblue", main = "Todos", ylab = "Viviendas por municipio y tipo")
abline(h = mean(ventas), col = "red", lty = 2)
boxplot(segunda, col = "lightblue", main = "Segunda mano", ylab = "Viviendas por municipio")
abline(h = mean(segunda), col = "red", lty = 2)
boxplot(nueva, col = "orange", main = "Vivienda nueva", ylab = "Viviendas por municipio")
abline(h = mean(nueva), col = "red", lty = 2)
par(mfrow = c(1, 1))
dev.off()
png("resultados/categorias.png", width = 1500, height = 850, res = 150)
porcentajes.todos = 100 * prop.table(table(categoria))
porcentajes.grafico = cbind(Todos = porcentajes.todos, porcentajes3)
barplot(porcentajes.grafico, col = c("lightblue", "steelblue", "navy"),
         ylim = c(0, 120), ylab = "Registros (%)",
         main = "Figura 3. Categorias de viviendas vendidas",
         legend.text = rownames(tabla3),
         args.legend = list(x = "topright", horiz = TRUE, cex = 0.8))
dev.off()

