
Add-Type -AssemblyName System.Drawing
$html = Get-Content "index_clean.html" -Raw

$images = @("perfil.jpg", "tiempo-extra.png", "radio-marca.png", "voz-galicia.png")
foreach ($imgName in $images) {
    if (Test-Path $imgName) {
        $img = [System.Drawing.Image]::FromFile((Join-Path $PWD $imgName))
        $ratio = $img.Width / $img.Height
        $newW = 150
        $newH = [math]::Max(1, [int]($newW / $ratio))
        
        $bmp = New-Object System.Drawing.Bitmap($newW, $newH)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, 0, 0, $newW, $newH)
        
        $ms = New-Object System.IO.MemoryStream
        $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $b64 = [Convert]::ToBase64String($ms.ToArray())
        
        $ms.Dispose()
        $bmp.Dispose()
        $img.Dispose()
        $g.Dispose()

        $dataUri = "data:image/jpeg;base64," + $b64
        # Reemplazo directo
        $html = $html.Replace($imgName, $dataUri)
    }
}
Set-Content -Path "index.html" -Value $html -Encoding UTF8



