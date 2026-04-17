Add-Type -AssemblyName System.Drawing
function ShrinkAndBase64 {
    param($path, $maxW)
    $bmp = [System.Drawing.Image]::FromFile($path)
    $w = $bmp.Width
    $h = $bmp.Height
    if ($w -gt $maxW) {
        $h = [math]::Floor($h * ($maxW / $w))
        $w = $maxW
    }
    $newBmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($newBmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($bmp, 0, 0, $w, $h)
    $ms = New-Object System.IO.MemoryStream
    $newBmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bytes = $ms.ToArray()
    $g.Dispose(); $newBmp.Dispose(); $bmp.Dispose(); $ms.Dispose()
    return [Convert]::ToBase64String($bytes)
}

$b64_perfil = ShrinkAndBase64 "$PWD\perfil.jpg" 800
$b64_tiempo = ShrinkAndBase64 "$PWD\tiempo-extra.png" 800
$b64_radio = ShrinkAndBase64 "$PWD\radio-marca.png" 800
$b64_voz = ShrinkAndBase64 "$PWD\voz-galicia.png" 800

$html = Get-Content "$PWD\index.html" -Raw
$html = $html -replace 'src="perfil\.jpg"', "src='data:image/jpeg;base64,$b64_perfil'"
$html = $html -replace 'src="tiempo-extra\.png"', "src='data:image/jpeg;base64,$b64_tiempo'"
$html = $html -replace 'src="radio-marca\.png"', "src='data:image/jpeg;base64,$b64_radio'"
$html = $html -replace 'src="voz-galicia\.png"', "src='data:image/jpeg;base64,$b64_voz'"

[IO.File]::WriteAllText("$PWD\index_embedded.html", $html)
