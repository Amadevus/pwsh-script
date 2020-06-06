# Set-ActionFailed
```

NAME
    Set-ActionFailed
    
SYNOPSIS
    Sets an action status to failed.
    When the action exits it will be with an exit code of 1.
    Equivalent of `core.setFailed(message)`.
    
    
SYNTAX
    Set-ActionFailed [[-Message] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Message <String>
        Add issue message.
        
        Required?                    false
        Position?                    1
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
    
    
RELATED LINKS
    https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log
    https://github.com/actions/toolkit/tree/master/packages/core#exporting-variables

```

