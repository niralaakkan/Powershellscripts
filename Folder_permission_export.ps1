#Function to export the permissions of a location. 
function export_acl_csv() {
Param(
 
        [parameter(position=0)]
        $parent,
        [parameter(position=1)]
        $path
)
    $FolderPath = dir -Directory -Path $path -Force
    $Report = @()
    Foreach ($Folder in $FolderPath) {
        $Acl = Get-Acl -Path $Folder.FullName | Select -ExpandProperty Access | where {$_.IdentityReference -like "*HANOVER\*" -and $_.IdentityReference -inotlike "*NASPROXY*" -and $_.IdentityReference -inotlike "*Domain Admins*" -and $_.FileSystemRights -inotlike "FullControl*" -and $_.IdentityReference -inotlike "*ROLE-VIRTUAL-REMOTE-TEAM*"} 
        foreach ($Access in $acl)
            {
                $Properties = [ordered]@{'FolderName'=$Folder.FullName;'AD Group or User'=$Access.IdentityReference;'Permissions'=$Access.FileSystemRights;'Inherited'=$Access.IsInherited}
                $Report += New-Object -TypeName PSObject -Property $Properties
            }
    }
    $Report | Export-Csv -path $export_loc\$parent.csv -NoTypeInformation -Append -Force
    Write-Host "Succefully exported the ACL for" $path -ForegroundColor Green
}

$loc = Read-host "Enter the path"
$export_loc = Read-host "Enter the path to store the ACL permission"

Get-ChildItem $export_loc\ | Remove-Item -Force 

$folderlists = Get-ChildItem $loc -Directory | where {$_.PsIsContainer}
foreach ($folderlist in $folderlists) {
    $second_lists = Get-ChildItem $folderlist.FullName | where {($_.PsIsContainer) -and ($_.name -ne 'fempr')}
    foreach ($second_list in $second_lists) {
        $third_lists = Get-ChildItem $second_list.FullName | where {$_.PsIsContainer}
        if ($third_lists -eq $null) {
                Write-Host "Exporting ACL for the share"$second_list.BaseName -ForegroundColor Yellow
                export_acl_csv $folderlist.BaseName $second_list.FullName
        }
        else {
            foreach ($third_list in $third_lists) {
                $fourth_lists = Get-ChildItem $third_list.FullName | where {$_.PsIsContainer}
                if ($fourth_lists -eq $null) {
                    Write-Host "Exporting ACL for the share"$third_list.BaseName -ForegroundColor Yellow
                    export_acl_csv $folderlist.BaseName $third_list.FullName
                }
                else {
                    foreach ($fourth_list in $fourth_lists) {
                        $fifth_lists = Get-ChildItem $fourth_list.FullName | where {$_.PsIsContainer}
                        if ($fifth_lists -eq $null) {
                            Write-Host "Exporting ACL for the share"$fourth_list.BaseName -ForegroundColor Yellow
                            export_acl_csv $folderlist.BaseName $fourth_list.FullName
                        }
                        else {      
                            foreach ($fifth_list in $fifth_lists) {
                                Write-Host "Exporting ACL for the share"$folderlist.BaseName -ForegroundColor Yellow
                                export_acl_csv $folderlist.BaseName $fifth_list.FullName
                            }
                        }
                    }
                }
            }
        }
    }
}

