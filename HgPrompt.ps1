# For backwards compatibility
$global:HgPromptSettings = $global:PoshHgSettings

function Write-Prompt($Object, $ForegroundColor, $BackgroundColor = -1) {
    if ($BackgroundColor -lt 0) {
        Write-Host $Object -NoNewLine -ForegroundColor $ForegroundColor
    } else {
        Write-Host $Object -NoNewLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    }
}

function Write-HgStatus($status = (get-hgStatus $global:PoshHgSettings.GetFileStatus $global:PoshHgSettings.GetShelveStatus $global:PoshHgSettings.GetOutgoingStatus)) {
    if (!$status) { return }

    $s = $global:PoshHgSettings

    $branchFg = $s.BranchForegroundColor
    $branchBg = $s.BranchBackgroundColor
    
    if ($status.Behind) {
        $branchFg = $s.Branch2ForegroundColor
        $branchBg = $s.Branch2BackgroundColor
    }

    if ($status.MultipleHeads) {
        $branchFg = $s.Branch3ForegroundColor
        $branchBg = $s.Branch3BackgroundColor
    }
   
    $written = $false

    Write-Prompt $s.BeforeText -BackgroundColor $s.BeforeBackgroundColor -ForegroundColor $s.BeforeForegroundColor
    if ($status.Error) {
        Write-Prompt $status.Error -BackgroundColor $s.ErrorBackgroundColor -ForegroundColor $s.ErrorForegroundColor
    }

    if ($status.Branch -ne 'default') {
        Write-Prompt $status.Branch -BackgroundColor $branchBg -ForegroundColor $branchFg
        $written = $true
    }

    if ($status.Behind) {
        Write-Prompt ('#' + $status.Commit.Split(':')[0]) -BackgroundColor $branchBg -ForegroundColor $branchFg
        $written = $true
    }

    if ($s.ShowShelved -and ($status.ShelvedThis -or $status.ShelvedOther)) {
        Write-Prompt ('(s:{0}/{1})' -f $status.ShelvedThis, $status.ShelvedOther) -BackgroundColor $s.ShelvedBackgroundColor -ForegroundColor $s.ShelvedForegroundColor
        $written = $true
    }
    
    function write-element($ename, $w) {
        if ($status.$ename) {
            $text = $s."$($ename)StatusPrefix" + $status.$ename
            if (!$w) {
                $text = $text.trim()
            }
            Write-Prompt $text -BackgroundColor $s."$($ename)BackgroundColor" -ForegroundColor $s."$($ename)ForegroundColor"
            $w = $true
        }
        $w
    }

    $written = write-element Added $written
    $written = write-element Modified $written
    $written = write-element Deleted $written
    $written = write-element Untracked $written
    $written = write-element Missing $written
    $written = write-element Renamed $written

    if ($s.ShowTags -and ($status.Tags.Length -or $status.Bookmarks.Length)) {
        if ($written) {
            write-host $s.BeforeTagText -NoNewLine
        }
        
        if ($status.Bookmarks.Length) {
            Write-Prompt $status.Bookmarks -ForegroundColor $s.BranchForegroundColor -BackgroundColor $s.TagBackgroundColor 
            if ($status.Tags.Length) {
                Write-Prompt " " -ForegroundColor $s.TagSeparatorColor -BackgroundColor $s.TagBackgroundColor
            }
        }
     
        $tagCounter=0
        $status.Tags | % {
        $color = $s.TagForegroundColor

        Write-Prompt $_ -ForegroundColor $color -BackgroundColor $s.TagBackgroundColor 

        if ($tagCounter -lt ($status.Tags.Length -1)) {
            Write-Prompt ", " -ForegroundColor $s.TagSeparatorColor -BackgroundColor $s.TagBackgroundColor
        }
            $tagCounter++;
        }        
    }

    if ($s.ShowPatches) {
        $patches = Get-MqPatches
        if ($patches.All.Length) {
            write-host $s.BeforePatchText -NoNewLine

            $patchCounter = 0

            $patches.Applied | % {
                Write-Prompt $_ -ForegroundColor $s.AppliedPatchForegroundColor -BackgroundColor $s.AppliedPatchBackgroundColor
                if ($patchCounter -lt ($patches.All.Length -1)) {
                    Write-Prompt $s.PatchSeparator -ForegroundColor $s.PatchSeparatorColor
                }
                $patchCounter++;
            }

            $patches.Unapplied | % {
                Write-Prompt $_ -ForegroundColor $s.UnappliedPatchForegroundColor -BackgroundColor $s.UnappliedPatchBackgroundColor
                if ($patchCounter -lt ($patches.All.Length -1)) {
                    Write-Prompt $s.PatchSeparator -ForegroundColor $s.PatchSeparatorColor
                }
                $patchCounter++;
            }
        }
    }

    if ($status.outgoing) {
        write-host ' ' -NoNewLine
        Write-Prompt $s.OutgoingText -ForegroundColor $s.OutgoingForegroundColor -BackgroundColor $s.OutgoingBackgroundColor
    }
    
    Write-Prompt $s.AfterText -BackgroundColor $s.AfterBackgroundColor -ForegroundColor $s.AfterForegroundColor
}

# Should match https://github.com/dahlbyk/posh-git/blob/master/GitPrompt.ps1
if ((Get-Variable -Scope Global -Name VcsPromptStatuses -ErrorAction SilentlyContinue) -eq $null) {
    $Global:VcsPromptStatuses = @()
}

function Global:Write-VcsStatus { $Global:VcsPromptStatuses | foreach { & $_ } }

# Add scriptblock that will execute for Write-VcsStatus
$Global:VcsPromptStatuses += {
    Write-HgStatus
}
