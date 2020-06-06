# Set-ActionOutput
```

NAME
    Set-ActionOutput
    
SYNOPSIS
    Sets the value of an output.
    Equivalent of `core.setOutput(name, value)`.
    
    
SYNTAX
    Set-ActionOutput [-Name] <String> [-Value] <Object> [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Name <String>
        Name of the output to set.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Value <Object>
        Value to store. Non-string values will be converted to a string via ConvertTo-Json.
        
        Required?                    true
        Position?                    2
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
    https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-an-output-parameter
    https://github.com/actions/toolkit/tree/master/packages/core#exporting-variables

```

