# Publica los cambios en GitHub Pages.
# Uso:  .\deploy.ps1                 -> mensaje "actualizacion"
#       .\deploy.ps1 "nuevo overlay" -> mensaje propio
param([string]$msg = "actualizacion")

git add -A
git commit -m $msg
git push origin main
# gh-pages es solo la copia que publica GitHub Pages: se sincroniza con main
git push origin main:gh-pages --force
Write-Host "Listo. https://seckbeth.github.io/torneos/" -ForegroundColor Green
