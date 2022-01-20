echo 1 2 3 4 5 6 7 | Chunk-Object -ElementsPerChunk 2;
Write-Host "=============================================================================";
(echo 1 2 3 4 5 6 7 | Chunk-Object -ElementsPerChunk 2).gettype();
Write-Host "=============================================================================";
(echo 1 2 3 4 5 6 7 | Chunk-Object -ElementsPerChunk 2).length;

Url: https://stackoverflow.com/questions/20871425/powershell-function-to-chunk-the-pipe-line-objects-into-arrays-cant-get-the-cor 