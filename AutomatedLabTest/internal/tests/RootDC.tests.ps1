﻿param
(
    [Parameter(Mandatory)]
    [AutomatedLab.Lab]
    $Lab
)

Describe "$($Lab.Name) DC Generic" -Tag RootDC,DC,FirstChildDC {

    Context "Role deployment successful" {
        It "Should return the correct amount of machines" {
            (Get-LabVm -Role ADDS).Count | Should -Be $Lab.Machines.Where({$_.Roles.Name -contains 'RootDC' -or $_.Roles.Name -contains 'DC' -or $_.Roles.Name -contains 'FirstChildDC'}).Count
        }

        foreach ($vm in (Get-LabVM -Role ADDS))
        {
            It "$vm should have ADWS running" {
                Invoke-LabCommand -ComputerName $vm -ScriptBlock {
                    (Get-Service -Name ADWS).Status.ToString()
                } -PassThru -NoDisplay | Should -Be Running
            }
        }
    }
}

Describe "$($Lab.Name) RootDC specific" -Tag RootDC {
    foreach ($vm in (Get-LabVm -Role RootDC))
    {
        It "$vm should hold domain naming master FSMO role" {
            Invoke-LabCommand -ComputerName $vm -ScriptBlock { (Get-ADForest).DomainNamingMaster} -PassThru -NoDisplay | Should -Be $vm.FQDN
        }
    }
}
