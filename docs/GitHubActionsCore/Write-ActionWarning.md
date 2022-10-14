# Write-ActionWarning
```

NAME
    Write-ActionWarning
    
SYNOPSIS
    Adds a warning issue.
    Equivalent of `core.warning(message)`.
    
    
SYNTAX
    Write-ActionWarning [[-Message] <String>] [-File] <String> [-Line] <Int32> [-Column] <Int32> [<CommonParameters>]
    
    Write-ActionWarning [[-Message] <String>] [-File] <String> [-Line] <Int32> [<CommonParameters>]
    
    Write-ActionWarning [[-Message] <String>] [-File] <String> [<CommonParameters>]
    
    Write-ActionWarning [[-Message] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Message <String>
        Warning issue message.
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -File <String>
        Filename where the issue occured.
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Line <Int32>
        Line number of the File where the issue occured.
        
        Required?                    true
        Position?                    3
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Column <Int32>
        Column number in Line in File where the issue occured.
        
        Required?                    true
        Position?                    4
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
NOTES
    
    
        File, Line and Column parameters are supported by the actual workflow command,
        but not available in `@actions/core` package.
    
    
RELATED LINKS
    https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-a-warning-message
    https://github.com/actions/toolkit/tree/main/packages/core#logging

```

