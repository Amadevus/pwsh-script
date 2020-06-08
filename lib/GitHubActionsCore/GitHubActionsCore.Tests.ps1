Import-Module $PSScriptRoot

Describe "Get-ActionInput" {
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