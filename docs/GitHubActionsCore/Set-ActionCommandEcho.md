# Set-ActionCommandEcho
```

NAME
    Set-ActionCommandEcho
    
SYNOPSIS
    Enables or disables the echoing of commands into stdout for the rest of the step.
    Echoing is disabled by default if ACTIONS_STEP_DEBUG is not set.
    Equivalent of `core.setCommandEcho(enabled)`.
    
    
SYNTAX
    Set-ActionCommandEcho [-Enabled] <Boolean> [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Enabled <Boolean>
        $true to enable echoing, $false to disable.
        
        Required?                    true
        Position?                    1
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
    https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#echoing-command-outputs

```

