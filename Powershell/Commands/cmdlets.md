Get-Command : list of commands<br>
Get-Help : Displays information about a cmdlet, e.g. <b>Get-Help Command-Name</b>
> Also understand how exactly to use the command by passing in the -examples flag, e.g. <b>Get-Help Get-Command -Examples</b>
#### Get-Command Verb-* or Get-Command *-Noun
> <b>Get-Command New-*</b> to view all the cmdlets for the verb new
### Object Manipulation
Since output of every cmdlet is object it can be manipulated:
- passing output to other cmdlets
- using specific object cmdlets to extract information

The Pipeline(|) is used to pass output from one cmdlet to another. A major difference compared to other shells is that instead of passing text or string to the command after the pipe, powershell passes an object to the next cmdlet.<br>
<br>
Object contains methods and properties. You can think of methods as functions that can be applied to output from the cmdlet and you can think of properties as variables in the output from a cmdlet. To view these details, pass the output of a cmdlet to the Get-Member cmdlet
> Verb-Noun | Get-Member  
> Get-Command | Get-Member -MemberType Method

