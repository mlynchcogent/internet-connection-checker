Write-Host "                                                  " -ForegroundColor White -BackgroundColor Blue
Write-Host "  Anton's continuous internet connection checker  " -ForegroundColor White -BackgroundColor Blue
Write-Host "                                                  " -ForegroundColor White -BackgroundColor Blue
Write-Host ""
Write-Host " Started at" (get-date).ToString('T')
Write-Host ""

$stop = 0
$attempt = 1

$stopwatch = [system.diagnostics.stopwatch]::StartNew()
$lastAttemptTimestamp = $stopwatch.Elapsed.TotalSeconds
$currentTimestamp = $stopwatch.Elapsed.TotalSeconds
$secondsConnected = 0
$secondsDisconnected = 0
$connectedSince = 0
$connectedSinceMs = 0
$disconnectedSince = 0
$disconnectedSinceMs = 0
$previousStatus = "None"

$cursorResetPosition = $host.UI.RawUI.CursorPosition
$cursorCurrentPosition = $host.UI.RawUI.CursorPosition
$cursorExitPosition = $host.UI.RawUI.CursorPosition

do {
  ### Start ping
  $host.UI.RawUI.CursorPosition = $cursorResetPosition
  Write-Host " Pinging google.com... " -NoNewLine -ForegroundColor Yellow
  $cursorCurrentPosition = $host.UI.RawUI.CursorPosition
  $host.UI.RawUI.CursorPosition = $cursorExitPosition
  $ping = test-connection -comp www.google.com -Quiet
  $host.UI.RawUI.CursorPosition = $cursorCurrentPosition

  ### Update result
  $currentTimestamp = $stopwatch.Elapsed.TotalSeconds
  if ($ping) {
    if ($previousStatus -ne "Connected") {
      $connectedSince = (get-date)
      $connectedSinceMs = $currentTimestamp
    }
    $secondsConnected += $currentTimestamp - $lastAttemptTimestamp

    Write-Host "[ Connected ]" -NoNewLine -ForegroundColor Black -BackgroundColor Green
    Write-Host " since " -NoNewLine -ForegroundColor Yellow
    $roundedConnectedSince = [math]::Round($currentTimestamp - $connectedSinceMs)
    Write-Host $connectedSince.ToString('T') "($roundedConnectedSince s ago)" -NoNewLine -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "              "

    $previousStatus = "Connected"
  } else {
    if ($previousStatus -ne "Disconnected") {
      $disconnectedSince = (get-date)
      $disconnectedSinceMs = $currentTimestamp
    }
    $secondsDisconnected += $currentTimestamp - $lastAttemptTimestamp

    Write-Host "[ Disconnected ]" -NoNewLine -ForegroundColor Black -BackgroundColor Red
    Write-Host " since " -NoNewLine -ForegroundColor Yellow
    $roundedConnectedSince = [math]::Round($currentTimestamp - $disconnectedSinceMs)
    Write-Host $disconnectedSince.ToString('T') "($roundedConnectedSince s ago)" -NoNewLine -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "              "

    $previousStatus = "Disconnected"
  }

  ### Display status bar
  $statusBarLength = 10
  $connectedPercentage = ($secondsConnected / ($secondsConnected + $secondsDisconnected)) * 100
  $connectedPercentageLength = ($connectedPercentage / 100) * $statusBarLength
  $disconnectedPercentageLength = $statusBarLength - $connectedPercentageLength
  Write-Host ""
  Write-Host " Uptime: [" -NoNewLine
  for ($i = 0; $i -lt $connectedPercentageLength; $i++) {
    Write-Host " " -NoNewLine -BackgroundColor Green
  }
  Write-Host "|" -NoNewLine -BackgroundColor Yellow -ForegroundColor White
  for ($i = 0; $i -lt $disconnectedPercentageLength; $i++) {
    Write-Host " " -NoNewLine -BackgroundColor Red
  }
  $roundedConnectedPercentage = [math]::Round($connectedPercentage)
  Write-Host "] $roundedConnectedPercentage%"
  $roundedSecondsConnected = [math]::Round($secondsConnected)
  $roundedSecondsDisconnected = [math]::Round($secondsDisconnected)
  Write-Host " Connected for" $roundedSecondsConnected "s, disconnected for" $roundedSecondsDisconnected "s"

  ### Reset
  Write-Host "" -NoNewLine
  $lastAttemptTimestamp = $currentTimestamp
  $attempt++
  $cursorExitPosition = $host.UI.RawUI.CursorPosition
} until ($stop -eq 1)

