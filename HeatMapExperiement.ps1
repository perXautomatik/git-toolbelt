$PSStyle.Progress.View = 'Classic'
for($I = 0; $I -lt 10; $I++ ) {
  $OuterLoopProgressParameters = @{
    Activity = 'Updating'
    Status = 'Progress->'
    PercentComplete = $I * 10
    CurrentOperation = 'OuterLoop'
  }
  Write-Progress @OuterLoopProgressParameters
  for($j = 1; $j -lt 101; $j++ ) {
    $InnerLoopProgressParameters = @{
      ID = 1
      Activity = 'Updating'
      Status = 'Progress'
      PercentComplete = $j
      CurrentOperation = 'InnerLoop'
    }
    Write-Progress @InnerLoopProgressParameters
    Start-Sleep -Milliseconds 25
  }
}