# Invoke-ActionNoCommandsBlock
```

NAME
    Invoke-ActionNoCommandsBlock
    
SYNOPSIS
    Invokes a scriptblock that won't result in any output interpreted as a workflow command.
    Useful for printing arbitrary text that may contain command-like text.
    No quivalent in `@actions/core` package.
    
    
SYNTAX
    Invoke-ActionNoCommandsBlock [-EndToken] <String> [-ScriptBlock] <ScriptBlock> [<CommonParameters>]
    
    Invoke-ActionNoCommandsBlock [-ScriptBlock] <ScriptBlock> -GenerateToken [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -EndToken <String>
        String token to stop workflow commands, used after scriptblock to start workflow commands back.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ScriptBlock <ScriptBlock>
        Script block to invoke within a no-commands context.
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -GenerateToken [<SwitchParameter>]
        Use this to automatically generate a GUID and use it as the EndToken.
        
        Required?                    true
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
    https://help.github.com/en/actions/reference/workflow-commands-for-github-actions#stopping-and-starting-workflow-commands

```

