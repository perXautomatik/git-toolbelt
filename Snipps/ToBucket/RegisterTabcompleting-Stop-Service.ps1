<#
The first command creates a script block that takes the required parameters which are passed in when the user presses Tab. 
The script block retrieves all running services and filters them by the word the user typed before pressing Tab. 
Then it creates a CompletionResult object for each service name and returns it. 
The second command registers the argument completer by passing the script block, 
the CommandName Stop-Service and the ParameterName Name.

According to the first search result1, there is no built-in cmdlet to list all the argument completers that are currently defined. 
However, you can use the following line of code to read the argument completers from the ExecutionContext:

$ExecutionContext._invokeCommand._context.CustomArgumentCompleters.Keys

#>

$s = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $services = Get-Service | Where-Object {$_.Status -eq "Running" -and $_.Name -like "$wordToComplete*"}
  $services | ForEach-Object {
    New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_.Name, $_.Name, "ParameterValue", $_.Name
  }
}
Register-ArgumentCompleter -CommandName Stop-Service -ParameterName Name -ScriptBlock $s
