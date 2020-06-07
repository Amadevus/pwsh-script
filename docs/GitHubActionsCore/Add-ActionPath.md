# Add-ActionPath
```

NAME
    Add-ActionPath
    
SYNOPSIS
    Prepends path to the PATH (for this action and future actions).
    Equivalent of `core.addPath(path)`.
    
    
SYNTAX
    Add-ActionPath [-Path] <String> [-SkipLocal] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Path <String>
        The new path to add.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -SkipLocal [<SwitchParameter>]
        Do not prepend path to current action's/step's environment PATH.
        
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
    https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#adding-a-system-path
    https://github.com/actions/toolkit/tree/master/packages/core#path-manipulation

```

