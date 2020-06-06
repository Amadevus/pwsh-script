# Set-ActionVariable
```

NAME
    Set-ActionVariable
    
SYNOPSIS
    Sets env variable for this action and future actions in the job.
    Equivalent of `core.exportVariable(name, value)`.
    
    
SYNTAX
    Set-ActionVariable [-Name] <String> [-Value] <Object> [-SkipLocal] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Name <String>
        The name of the variable to set.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Value <Object>
        The value of the variable. Non-string values will be converted to a string via ConvertTo-Json.
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -SkipLocal [<SwitchParameter>]
        Do not set variable in current action's/step's environment.
        
        Required?                    false
        Position?                    named
        Default value                False
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
    https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-an-environment-variable
    https://github.com/actions/toolkit/tree/master/packages/core#exporting-variables

```

