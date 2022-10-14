# Enter-ActionOutputGroup
```

NAME
    Enter-ActionOutputGroup
    
SYNOPSIS
    Begin an output group.
    Output until the next `groupEnd` will be foldable in this group.
    Equivalent of `core.startGroup(name)`.
    
    
SYNTAX
    Enter-ActionOutputGroup [-Name] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Output until the next `groupEnd` will be foldable in this group.
    

PARAMETERS
    -Name <String>
        The name of the output group.
        
        Required?                    true
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
    https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines
    https://github.com/actions/toolkit/tree/main/packages/core#logging

```

