# Send-ActionFileCommand
```

NAME
    Send-ActionFileCommand
    
SYNOPSIS
    Sends a command to an Action Environment File.
    Equivalent to `core.issueFileCommand(cmd, msg)`.
    
    
SYNTAX
    Send-ActionFileCommand [-Command] <String> [-Message] <PSObject> [<CommonParameters>]
    
    
DESCRIPTION
    Appends given message to an Action Environment File.
    

PARAMETERS
    -Command <String>
        Command (environment file variable suffix) to send message for.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Message <PSObject>
        Message to append.
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS>Send-ActionFileCommand ENV 'myvar=value'
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS>'myvar=value', 'myvar2=novalue' | Send-ActionFileCommand ENV
    
    
    
    
    
    
    
RELATED LINKS
    https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#environment-files

```

