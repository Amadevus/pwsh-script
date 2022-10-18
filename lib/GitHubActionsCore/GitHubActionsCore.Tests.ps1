#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.1' }

BeforeAll {
    Import-Module $PSScriptRoot -Force
}

Describe 'Get-ActionInput' {
    BeforeEach {
        $env:INPUT_TEST_INPUT = $null
    }
    Context "When requested input doesn't exist" {
        It "Should return empty string" {
            $result = Get-ActionInput TEST_INPUT
            $result | Should -Be ''
        }
        It "Given Required switch, it throws" {
            {
                Get-ActionInput TEST_INPUT -Required
            } | Should -Throw
        }
    }
    Context "When requested input exists" {
        It "Should return it's value" {
            $env:INPUT_TEST_INPUT = 'test value'

            $result = Get-ActionInput TEST_INPUT

            $result | Should -Be 'test value'
        }
        It "Should trim the returned value" {
            $env:INPUT_TEST_INPUT = "`n  test value `n  `n"

            $result = Get-ActionInput TEST_INPUT

            $result | Should -Be 'test value'
        }
    }
    Context "When input name contains spaces" {
        It "Should replace them with underscores" {
            $env:INPUT_TEST_INPUT = 'test value'

            $result = Get-ActionInput 'test input'

            $result | Should -Be 'test value'
        }
    }
    AfterEach {
        $env:INPUT_TEST_INPUT = $null
    }
}
Describe 'Set-ActionOutput' {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Used in AfterAll')]
        $oldGithubOut = $env:GITHUB_OUTPUT
    }
    BeforeEach {
        $env:GITHUB_OUTPUT = $null
    }
    AfterAll {
        $env:GITHUB_OUTPUT = $oldGithubOut
    }
    Context "Given value '<value>'" -Foreach @(
        @{ Value = ''; ExpectedCmd = ''; ExpectedEnv = $null }
        @{ Value = 'test value'; ExpectedCmd = 'test value'; ExpectedEnv = 'test value' }
        @{ Value = "test `n multiline `r`n value"; ExpectedCmd = 'test %0A multiline %0D%0A value'; ExpectedEnv = "test `n multiline `r`n value"; Multiline = $true }
        @{ Value = 'A % B'; ExpectedCmd = 'A %25 B'; ExpectedEnv = 'A % B' }
        @{ Value = [ordered]@{ a = '1x'; b = '2y' }; ExpectedCmd = '{"a":"1x","b":"2y"}'; ExpectedEnv = '{"a":"1x","b":"2y"}' }
    ) {
        Context "When GITHUB_OUTPUT not set" {
            BeforeAll {
                Mock Write-Host { } -ModuleName GitHubActionsCore
            }
            It "Sends command with '<expectedcmd>'" {
                Set-ActionOutput 'my-result' $Value
        
                Should -Invoke Write-Host -ParameterFilter {
                    $Object -eq "::set-output name=my-result::$ExpectedCmd"
                } -ModuleName GitHubActionsCore
            }
        }
        Context "When GITHUB_OUTPUT is set" {
            BeforeEach {
                $testPath = 'TestDrive:/out-cmd.env'
                Set-Content $testPath '' -NoNewline
                $env:GITHUB_OUTPUT = $testPath
            }
            It "Appends command file with formatted command '<expectedenv>'" {
                Set-ActionOutput 'my-result' $Value
        
                $eol = [System.Environment]::NewLine
                if ($Multiline) {
                    $null, $delimiter = (Get-Content $testPath)[0] -split "<<"
                    Get-Content $testPath -Raw
                    | Should -BeExactly "my-result<<$delimiter${eol}$ExpectedEnv${eol}$delimiter${eol}"
                }
                else {
                    Get-Content $testPath -Raw
                    | Should -BeExactly "my-result=$ExpectedEnv${eol}"
                }
            }
        }
    }
}
Describe 'Add-ActionSecret' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Sends appropriate workflow command to host" {
        Add-ActionSecret 'test value'

        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq '::add-mask::test value'
        } -ModuleName GitHubActionsCore
    }
}
Describe 'Set-ActionVariable' {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Used in AfterAll')]
        $oldGithubEnv = $env:GITHUB_ENV
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Used in AfterAll')]
        $oldTestVar = $env:TESTVAR
    }
    BeforeEach {
        $env:GITHUB_ENV = $null
        $env:TESTVAR = $null
    }
    AfterAll {
        $env:GITHUB_ENV = $oldGithubEnv
        $env:TESTVAR = $oldTestVar
    }
    Context "Given value '<value>'" -Foreach @(
        @{ Value = ''; ExpectedCmd = ''; ExpectedEnv = $null }
        @{ Value = 'test value'; ExpectedCmd = 'test value'; ExpectedEnv = 'test value' }
        @{ Value = "test `n multiline `r`n value"; ExpectedCmd = 'test %0A multiline %0D%0A value'; ExpectedEnv = "test `n multiline `r`n value"; Multiline = $true }
        @{ Value = 'A % B'; ExpectedCmd = 'A %25 B'; ExpectedEnv = 'A % B' }
        @{ Value = [ordered]@{ a = '1x'; b = '2y' }; ExpectedCmd = '{"a":"1x","b":"2y"}'; ExpectedEnv = '{"a":"1x","b":"2y"}' }
    ) {
        Context "When GITHUB_ENV not set" {
            BeforeAll {
                Mock Write-Host { } -ModuleName GitHubActionsCore
            }
            It "Sends command with '<expectedcmd>' and sets env var to '<expectedenv>'" {
                Set-ActionVariable TESTVAR $Value
        
                $env:TESTVAR | Should -Be $ExpectedEnv
                Should -Invoke Write-Host -ParameterFilter {
                    $Object -eq "::set-env name=TESTVAR::$ExpectedCmd"
                } -ModuleName GitHubActionsCore
            }
            It "Sends command with '<expectedcmd>' and doesn't set env var due to -SkipLocal" {
                Set-ActionVariable TESTVAR $Value -SkipLocal
        
                $env:TESTVAR | Should -BeNullOrEmpty
                Should -Invoke Write-Host -ParameterFilter {
                    $Object -eq "::set-env name=TESTVAR::$ExpectedCmd"
                } -ModuleName GitHubActionsCore
            }
        }
        Context "When GITHUB_ENV is set" {
            BeforeEach {
                $testPath = 'TestDrive:/env-cmd.env'
                Set-Content $testPath '' -NoNewline
                $env:GITHUB_ENV = $testPath
            }
            It "Appends command file with formatted command and sets env var to '<expectedenv>'" {
                Set-ActionVariable TESTVAR $Value
        
                $env:TESTVAR | Should -Be $ExpectedEnv
                $eol = [System.Environment]::NewLine
                if ($Multiline) {
                    $null, $delimiter = (Get-Content $testPath)[0] -split "<<"
                    Get-Content $testPath -Raw
                    | Should -BeExactly "TESTVAR<<$delimiter${eol}$ExpectedEnv${eol}$delimiter${eol}"
                }
                else {
                    Get-Content $testPath -Raw
                    | Should -BeExactly "TESTVAR=$ExpectedEnv${eol}"
                }
            }
            It "Appends command file with formatted command and doesn't set env var due to -SkipLocal" {
                Set-ActionVariable TESTVAR $Value -SkipLocal
        
                $env:TESTVAR | Should -BeNullOrEmpty
                $eol = [System.Environment]::NewLine
                if ($Multiline) {
                    $null, $delimiter = (Get-Content $testPath)[0] -split "<<"
                    Get-Content $testPath -Raw
                    | Should -BeExactly "TESTVAR<<$delimiter${eol}$ExpectedEnv${eol}$delimiter${eol}"
                }
                else {
                    Get-Content $testPath -Raw
                    | Should -BeExactly "TESTVAR=$ExpectedEnv${eol}"
                }
            }
        }
    }
}
Describe 'Add-ActionPath' {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Used in AfterAll')]
        $oldPath = $env:PATH
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Used in AfterAll')]
        $oldGithubPath = $env:GITHUB_PATH
    }
    BeforeEach {
        $env:PATH = $oldPath
        $env:GITHUB_PATH = $null
    }
    AfterAll {
        $env:PATH = $oldPath
        $env:GITHUB_PATH = $oldGithubPath
    }
    Context "When GITHUB_PATH is not set" {
        BeforeAll {
            Mock Write-Host { } -ModuleName GitHubActionsCore
        }
        It "Sends appropriate workflow command to host and prepends PATH" {
            Add-ActionPath 'test path'
    
            $env:PATH | Should -BeLike "test path$([System.IO.Path]::PathSeparator)*" -Because 'PATH should be also prepended in current scope'
            Should -Invoke Write-Host -ParameterFilter {
                $Object -eq '::add-path::test path'
            } -ModuleName GitHubActionsCore
        }
        It "Given SkipLocal switch, sends command but doesn't change PATH" {
            $path = $env:PATH
    
            Add-ActionPath 'test path' -SkipLocal
    
            $env:PATH | Should -Be $path -Because "PATH shouldn't be modified"
            Should -Invoke Write-Host -ParameterFilter {
                $Object -eq '::add-path::test path'
            } -ModuleName GitHubActionsCore
        }
    }
    Context "When GITHUB_PATH is set" {
        BeforeEach {
            $testPath = 'TestDrive:/path-cmd.env'
            Set-Content $testPath '' -NoNewline
            $env:GITHUB_PATH = $testPath
        }
        It "Sends appropriate workflow command to command file and prepends PATH" {
            Add-ActionPath 'test path'
    
            $env:PATH | Should -BeLike "test path$([System.IO.Path]::PathSeparator)*" -Because 'PATH should be also prepended in current scope'
            Get-Content $testPath -Raw
            | Should -BeExactly "test path$([System.Environment]::NewLine)"
        }
        It "Sends appropriate workflow command to command file but doesn't change PATH due to -SkipLocal" {
            $path = $env:PATH
    
            Add-ActionPath 'test path' -SkipLocal
    
            $env:PATH | Should -Be $path -Because "PATH shouldn't be modified"
            Get-Content $testPath -Raw
            | Should -BeExactly "test path$([System.Environment]::NewLine)"
        }
    }
}
Describe 'Set-ActionCommandEcho' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Given '<value>' should send a workflow command to turn echoing commands <expected>" -TestCases @(
        @{ Value = $false; Expected = 'off' }
        @{ Value = $true; Expected = 'on' }
    ) {
        Set-ActionCommandEcho $Value

        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq "::echo::$Expected"
        } -ModuleName GitHubActionsCore
    }
}
Describe 'Set-ActionFailed' {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Used in AfterAll')]
        $oldExitCode = [System.Environment]::ExitCode
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    BeforeEach {
        [System.Environment]::ExitCode = 0
    }
    It "Given message '<value>' should send error command with message '<expected> and set ExitCode to 1" -TestCases @(
        @{ Value = $null; Expected = '' }
        @{ Value = ''; Expected = '' }
        @{ Value = 'fail'; Expected = 'fail' }
        @{ Value = "first fail line`nsecond fail line"; Expected = 'first fail line%0Asecond fail line' }
    ) {
        Set-ActionFailed $Value

        [System.Environment]::ExitCode | Should -Be 1 -Because 'this exit code is expected to be used upon exit'
        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq "::error::$Expected"
        } -ModuleName GitHubActionsCore
    }
    AfterAll {
        [System.Environment]::ExitCode = $oldExitCode
    }
}
Describe 'Get-ActionIsDebug' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Used in AfterAll')]
        $oldEnvRunnerDebug = $env:RUNNER_DEBUG
    }
    BeforeEach {
        $env:RUNNER_DEBUG = $null
    }
    AfterAll {
        $env:RUNNER_DEBUG = $oldEnvRunnerDebug
    }
    It 'Given env var is not set, return false' {
        $result = Get-ActionIsDebug

        $result | Should -BeExactly $false
    }
    It "Given env var is set to '<value>' it returns '<expected>'" -TestCases @(
        @{ Value = $null; Expected = $false }
        @{ Value = 0; Expected = $false }
        @{ Value = 2; Expected = $false }
        @{ Value = 1; Expected = $true }
        @{ Value = '1'; Expected = $true }
        @{ Value = 'true'; Expected = $false }
    ) {
        $env:RUNNER_DEBUG = $Value

        $result = Get-ActionIsDebug
        
        $result | Should -BeExactly $Expected
    }
}
Describe 'Write-ActionError' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Given a message '<value>' sends a workflow command with it" -TestCases @(
        @{ Value = $null; Expected = '' }
        @{ Value = 'my error'; Expected = 'my error' }
        @{ Value = "my error`nsecond line"; Expected = 'my error%0Asecond line' }
    ) {
        Write-ActionError $Value
        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq "::error::$Expected"
        } -ModuleName GitHubActionsCore
    }
}
Describe 'Write-ActionWarning' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Given a message '<value>' sends a workflow command with it" -TestCases @(
        @{ Value = $null; Expected = '' }
        @{ Value = 'my warning'; Expected = 'my warning' }
        @{ Value = "my warning`nsecond line"; Expected = 'my warning%0Asecond line' }
    ) {
        Write-ActionWarning $Value
        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq "::warning::$Expected"
        } -ModuleName GitHubActionsCore
    }
}

Describe 'Write-ActionInfo' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Given a message '<value>' sends it to host" -TestCases @(
        @{ Value = 'my log'; Expected = 'my log' }
        @{ Value = "my log`nnewline"; Expected = "my log`nnewline" }
    ) {
        Write-ActionInfo $Value
        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq $Expected
        } -ModuleName GitHubActionsCore
    }
}
Describe 'Enter-ActionOutputGroup' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Given '<name>' sends a workflow command with it" -TestCases @(
        @{ Name = 'my group'; Expected = 'my group' }
        @{ Name = 'my group with percent%'; Expected = 'my group with percent%25' }
    ) {
        Enter-ActionOutputGroup $Name
        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq "::group::$Expected"
        } -ModuleName GitHubActionsCore
    }
}
Describe 'Exit-ActionOutputGroup' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Sends a workflow command" {
        Exit-ActionOutputGroup
        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq '::endgroup::'
        } -ModuleName GitHubActionsCore
    }
}
Describe 'Invoke-ActionGroup' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Given a scriptblock, sends a workflow command before and after it" {
        Invoke-ActionGroup 'my group' {
            Write-Output 'doing stuff'
        }
        @('::group::my group', '::endgroup::') | ForEach-Object {
            $cmd = $_
            Should -Invoke Write-Host -ParameterFilter {
                $Object -eq $cmd
            } -ModuleName GitHubActionsCore
        }
    }
}
Describe 'Invoke-ActionNoCommandsBlock' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Given a scriptblock, sends a workflow command before and after it" {
        Invoke-ActionNoCommandsBlock 'my block' {
            Write-Output 'doing stuff'
        }
        @('::stop-commands::my block', '::my block::') | ForEach-Object {
            $cmd = $_
            Should -Invoke Write-Host -ParameterFilter {
                $Object -eq $cmd
            } -ModuleName GitHubActionsCore
        }
    }
}
Describe 'Send-ActionCommand' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Given no command ('<value>') throws" -TestCases @(
        @{ Value = $null }
        @{ Value = '' }
    ) {
        {
            Send-ActionCommand -Command $Value
        } | Should -Throw "Cannot validate argument on parameter 'Command'. The argument is null or empty.*"
    }
    It "Given a command with message '<msg>' writes '<expected>' to host" -TestCases @(
        @{ Msg = $null; Expected = '::test-cmd::' }
        @{ Msg = ''; Expected = '::test-cmd::' }
        @{ Msg = 'a'; Expected = '::test-cmd::a' }
        @{ Msg = "a `r `n b : c % d"; Expected = '::test-cmd::a %0D %0A b : c %25 d' }
    ) {
        Send-ActionCommand test-cmd -Message $Msg

        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq $Expected
        } -ModuleName GitHubActionsCore
    }
    It "Given a command with params '<params>' writes '<expected>' to host" -TestCases @(
        @{ Params = @{ a = $null; b = '' }; Expected = '::test-cmd::' }
        @{ Params = @{ a = 'A' }; Expected = '::test-cmd a=A::' }
        @{ Params = [ordered]@{ a = 'A'; b = 'B' }; Expected = '::test-cmd a=A,b=B::' }
        @{ Params = [ordered]@{ a = "A `r B `n C : D , E % F" }; Expected = '::test-cmd a=A %0D B %0A C %3A D %2C E %25 F::' }
    ) {
        Send-ActionCommand test-cmd $Params

        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq $Expected
        } -ModuleName GitHubActionsCore
    }
}

Describe 'Send-ActionFileCommand' {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Used in AfterAll')]
        $oldGithubTestcmd = $env:GITHUB_TESTCMD
    }
    BeforeEach {
        $testPath = 'TestDrive:/testcmd.env'
        $env:GITHUB_TESTCMD = $testPath
    }
    AfterAll {
        $env:GITHUB_TESTCMD = $oldGithubTestcmd
    }
    Context "When file doesn't exist" {
        BeforeEach {
            Remove-Item $testPath -Force -ea:Ignore
        }
        It "Given no command ('<value>') throws" -TestCases @(
            @{ Value = $null }
            @{ Value = '' }
        ) {
            {
                Send-ActionFileCommand -Command $Value -Message 'foobar'
            } | Should -Throw "Cannot validate argument on parameter 'Command'. The argument is null or empty.*"
        }
        It "Given command for which env var doesn't exist" {
            $env:GITHUB_TESTCMD = $null
            {
                Send-ActionFileCommand -Command TESTCMD -Message 'foobar'
            } | Should -Throw 'Unable to find environment variable for file command TESTCMD'
        }
        It "Given command for which file doesn't exist" {
            {
                Send-ActionFileCommand -Command TESTCMD -Message 'foobar'
            } | Should -Throw 'Missing file at path: *testcmd.env'
        }
    }
    Context 'When file exists' {
        BeforeEach {
            Set-Content $testPath '' -NoNewline
        }
        It "Given a command with message '<msg>' writes '<expected>' to a file" -TestCases @(
            @{ Msg = ''; Expected = $null }
            @{ Msg = 'a'; Expected = $null }
            @{ Msg = "a `r `n b : c % d"; Expected = $null }
            @{ Msg = 1; Expected = $null }
            @{ Msg = $true; Expected = 'true' }
            @{ Msg = [ordered]@{ a = 1; b = $false }; Expected = '{"a":1,"b":false}' }
        ) {
            Send-ActionFileCommand TESTCMD -Message $Msg

            Get-Content $testPath -Raw | Should -BeExactly (($Expected ?? "$Msg") + [System.Environment]::NewLine)
        }
    }
}
