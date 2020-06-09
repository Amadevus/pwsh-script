Set-StrictMode -Version Latest

BeforeAll {
    Get-Module GitHubActionsCore | Remove-Module
    Import-Module $PSScriptRoot
}

Describe 'Get-ActionInput' {
    Context "When requested input doesn't exist" {
        It "Should return empty string" {
            $result = Get-ActionInput ([Guid]::NewGuid())
            $result | Should -Be ''
        }
        It "Given Required switch, it throws" {
            {
                Get-ActionInput ([Guid]::NewGuid()) -Required
            } | Should -Throw
        }
    }
    Context "When requested input exists" {
        It "Should return it's value" {
            Mock Get-ChildItem { @{Value = 'test value' } } {
                $Path -eq 'Env:INPUT_TEST_INPUT'
            } -ModuleName GitHubActionsCore

            $result = Get-ActionInput TEST_INPUT

            $result | Should -Be 'test value'
        }
        It "Should trim the returned value" {
            Mock Get-ChildItem { @{Value = "`n  test value `n  `n" } } {
                $Path -eq 'Env:INPUT_TEST_INPUT'
            } -ModuleName GitHubActionsCore

            $result = Get-ActionInput TEST_INPUT

            $result | Should -Be 'test value'
        }
    }
    Context "When input name contains spaces" {
        It "Should replace them with underscores" {
            Mock Get-ChildItem { @{Value = 'value' } } {
                $Path -eq 'Env:INPUT_TEST_INPUT'
            } -ModuleName GitHubActionsCore

            $result = Get-ActionInput 'test input'

            $result | Should -Be 'value'
        }
    }
}
Describe 'Set-ActionOutput' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    It "Sends appropriate workflow command to host" {
        Set-ActionOutput 'my-result' 'test value'

        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq '::set-output name=my-result::test value'
        } -ModuleName GitHubActionsCore
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
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    BeforeEach {
        Remove-Item "Env:my-var" -ErrorAction SilentlyContinue
    }
    It "Given value '<value>', sends command with '<expectedcmd>' and sets env var to '<expectedenv>'" -TestCases @(
        @{ Value = ''; ExpectedCmd = ''; ExpectedEnv = $null }
        @{ Value = 'test value'; ExpectedCmd = 'test value'; ExpectedEnv = 'test value' }
        @{ Value = 'A % B'; ExpectedCmd = 'A %25 B'; ExpectedEnv = 'A % B' }
        @{ Value = [ordered]@{ a = '1x'; b = '2y'}; ExpectedCmd = '{"a":"1x","b":"2y"}'; ExpectedEnv = '{"a":"1x","b":"2y"}' }
    ) {
        Set-ActionVariable 'my-var' $Value

        ${env:my-var} | Should -Be $ExpectedEnv
        Should -Invoke Write-Host -ParameterFilter {
            $Object -eq "::set-env name=my-var::$ExpectedCmd"
        } -ModuleName GitHubActionsCore
    }
    AfterEach {
        Remove-Item "Env:my-var" -ErrorAction SilentlyContinue
    }
}
Describe 'Add-ActionPath' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    BeforeEach {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Used in AfterEach')]
        $prevPath = [System.Environment]::GetEnvironmentVariable('PATH')
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
    AfterEach {
        [System.Environment]::SetEnvironmentVariable('PATH', $prevPath)
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
    AfterEach {
        [System.Environment]::ExitCode = 0
    }
}
Describe 'Get-ActionIsDebug' {
    BeforeAll {
        Mock Write-Host { } -ModuleName GitHubActionsCore
    }
    BeforeEach {
        Remove-Item Env:RUNNER_DEBUG -ErrorAction SilentlyContinue
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
    AfterEach {
        Remove-Item Env:RUNNER_DEBUG -ErrorAction SilentlyContinue
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