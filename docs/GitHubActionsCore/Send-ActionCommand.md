# Send-ActionCommand
```

NAME
    Send-ActionCommand
    
SYNOPSIS
    Sends a command to the hosting Workflow/Action context.
    Equivalent to `core.issue(cmd, msg)`/`core.issueCommand(cmd, props, msg)`.
    
    
SYNTAX
    Send-ActionCommand [-Command] <String> [-Properties] <IDictionary> [[-Message] <String>] [<CommonParameters>]
    
    Send-ActionCommand [-Command] <String> [[-Message] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Command Format:
      ::workflow-command parameter1={data},parameter2={data}::{command value}
    

PARAMETERS
    -Command <String>
        The workflow command name.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Properties <IDictionary>
        Properties to add to the command.
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Message <String>
        Message to add to the command.
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS>Send-ActionCommand warning 'This is the user warning message'
    ::warning::This is the user warning message
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS>Send-ActionCommand set-secret @{name='mypassword'} 'definitelyNotAPassword!'
    ::set-secret name=mypassword::definitelyNotAPassword!
    
    
    
    
    
    
    
RELATED LINKS
    https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#about-workflow-commands

```

