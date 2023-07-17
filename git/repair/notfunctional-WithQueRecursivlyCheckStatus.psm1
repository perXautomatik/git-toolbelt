cls

function Show-ProgressV3{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [PSObject[]]$InputObject,
        [string]$Activity = "Processing items"
    )

        [int]$TotItems = $Input.Count
        [int]$Count = 0

        $Input | foreach {
            'inside'+$TotItems
            $_
            $Count++
            [int]$percentComplete = ($Count/$TotItems* 100)
            Write-Progress -Activity $Activity -PercentComplete $percentComplete -Status ("Working - " + $percentComplete + "%")
        }
}

function enque { 
    
    param([Parameter(ValueFromPipeline)][psobject]$InputObjectx)
    
                    $output = $prop.name+$InputObjectx.length

                    $depth++

                    $InputObjectx | ?{$_.name -ne 'SyncRoot'} | % { $queue.Enqueue($_) }

}

function Resolve-Properties 
{
  param([Parameter(ValueFromPipeline)][psobject]$InputObject)

begin {
        $i = 0 
        $queue = [System.Collections.Queue]::new()    # get a new queue
        $toParse = $InputObject.psobject.Properties                   

}
process { 
            
            $toParse |  % { $queue.Enqueue($_) }
            $i = 0
            $depth = 0
            $tree = '\----\'
            $queue.Count
            $output = ''
            $iLessThan = 200


            
            while ($queue.Count -gt 0 -and $i -le $iLessThan)
            {
                $i++; $queue.Count
                $itemOfQue = $queue.Dequeue()                 # get one item off the queue
                $prop = $itemOfQue.psobject.Properties
                $subValue1 = $prop.value.children
                $subValue2 = $prop.children


                                                                                            
                if( $subValue1.length -gt 0)
                {
                    $subValue1 | enque
                }
                elseif ( $subValue2.length -gt 0 )
                {
                                 
                    $subValue2 | enque
                }

                else
                {
                    $output = $prop.value
                }

                $treex = $tree * $depth
                $treex + $output

            }  


        }    

  }
